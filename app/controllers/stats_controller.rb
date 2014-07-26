class StatsController < ApplicationController
  # {{{ def analytics
  def analytics
    store_ids = eval(params[:store_id])
    params[:num] ||= "0"
    num = params[:num].to_i
    surveys = MemberSurvey
      .where(store_id: store_ids, completed: true)
      .includes(:member_survey_answers)
      .order('created_at DESC')

    surveys = surveys.where('created_at >= ?', num.days.ago) if num > 0

    survey_data = {
      surveys: {
        count: surveys.count,
        total_count: MemberSurvey.where(store_id: store_ids, completed: true).count,
      },
      members: {
        total_count: MemberSurvey.where(store_id: store_ids, completed: true).uniq.pluck(:member_id).count,
      },
      questions: [],
      performance: {
        dates: [],
        points: [],
      },
      companies: []
    }

    @questions = {}
    @user_ids = []
    @performance = {}

    surveys.each do |survey|
      @user_ids << survey.member_id
      total_points = 0
      has_rewards = false
      company = survey.company
      survey_data[:companies].each do |comp|
        has_rewards = company[:id] == comp[:id]
        break if has_rewards
      end
      survey_data[:companies] << { 
        id: company[:id], 
        name: company[:name],
        rewards: company.rewards.collect do |reward|
          reward = reward[:reward] unless reward[:reward].nil?
          r = {
            cost: reward[:cost],
            id: reward[:id],
            title: reward[:title],
          }
        end
      } unless has_rewards
      survey.member_survey_answers.each do |answer|
        @questions[answer.question] ||= { points: [] }
        @questions[answer.question][:type] ||= answer.survey_question.answer_type
        points = answer.answer
        points = points.to_f if @questions[answer.question][:type] != 'switch'
        total_points += points if @questions[answer.question][:type] == 'slider'
        total_points += (points * 2) if @questions[answer.question][:type] == 'star_rating'
        @questions[answer.question][:points] << points
      end
      @performance[survey.created_at] ||= []
      @performance[survey.created_at] << total_points / survey.member_survey_answers.length
    end

    @performance.sort_by { |date, points| date }.each do |date, points|
      survey_data[:performance][:dates] << date
      survey_data[:performance][:points] << points.inject(0.0) { |sum, el| sum + el } / points.size
    end

    @questions.each do |q, data|
      data[:question] = q
      if data[:type] == 'switch'
        data[:avg_points] = data[:points].count { |x| x.upcase == 'YES' } / data[:points].size.to_f
      else
        data[:avg_points] = data[:points].inject(0.0) { |sum, el| sum + el } / data[:points].size
      end
      survey_data[:questions] << data
    end

    survey_data[:members][:count] = @user_ids.uniq.length

    render json: survey_data
  end
  # }}}
  # {{{ def surveys
  def surveys
    params[:limit] ||= 20
    params[:offset] ||= 0
    surveys = MemberSurvey
      .where(store_id: eval(params[:store_id]), completed: true)
      .order('created_at DESC')
      .limit(params[:limit])
      .offset(params[:offset])

    if surveys.nil?
      render json: []
    else
      render json: surveys.to_json(
        except: [
          :worth,
          :code_id,
          :company_id,
          :completed,
          :completed_time,
          :member_id,
          :order_id,
          :store_id,
        ],
        include: {
          member: {
            include: {
              member_attributes: {}
            },
            only: [
              :member_attributes
            ]
          },
          member_survey_answers: {
            include: {
              survey_question: {
                only: [
                  :answer_type
                ]
              }
            },
            only: [
              :answer
            ]
          },
        }
      )
    end
  end
  # }}}
  # {{{ def survey
  def survey
    survey = MemberSurvey.find(params[:id])
    survey ||= {}

    render json: survey.to_json(include: {
      company: {
        only: :name
      },
      member_survey_answers: {
        include: {
          survey_question: {}
        }
      },
      store: {
        only: :address1
      },
    })
  end
  # }}}
end
