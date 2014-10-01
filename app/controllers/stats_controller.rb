class StatsController < ApplicationController
  # {{{ def analytics
  # GET /analytics
  # GET /analytics.json
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
      }
    }

    @questions = {}
    @user_ids = []
    @performance = {}

    surveys.each do |survey|
      @user_ids << survey.member_id
      total_points = 0
      total_qs = 0
      survey.member_survey_answers.each do |answer|
        @questions[answer.question] ||= { points: [] }
        @questions[answer.question][:type] ||= answer.survey_question.answer_type
        points = answer.answer
        if @questions[answer.question][:type] != 'switch'
          points = points.to_f 
          total_qs += 1
        end
        total_points += points if @questions[answer.question][:type] == 'slider'
        total_points += (points * 2) if @questions[answer.question][:type] == 'star_rating'
        @questions[answer.question][:points] << points
      end
      if total_qs > 0
        @performance[survey.created_at] ||= []
        @performance[survey.created_at] << total_points / total_qs
      end
    end

    @performance.sort_by { |date, points| date }.each do |date, points|
      survey_data[:performance][:dates] << date
      if points.size > 0
        survey_data[:performance][:points] << points.inject(0.0) { |sum, el| sum + el } / points.size
      else
        survey_data[:performance][:points] << 0
      end
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

    puts survey_data.inspect

    render json: survey_data
  end
  # }}}
  # {{{ def surveys
  # GET /surveys
  # GET /surveys.json
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
  # GET /survey
  # GET /survey.json
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
