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
  # {{{ def store_ratings
  # def store_ratings
  #   member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('orders.created_at DESC')

  #   if params[:offset] && !member_surveys.nil?
  #     member_surveys = member_surveys.offset(params[:offset])
  #   end

  #   if params[:limit] && !member_surveys.nil?
  #     member_surveys = member_surveys.limit(params[:limit])
  #   end

  #   @answers = {}
  #   @surveys = []
  #   @total = 0
  #   @count = 0
  #   
  #   member_surveys.each do |survey|
  #     totals = 0
  #     counts = 0
  #     survey.member_survey_answers.each do |answer|
  #       if @answers[answer.answer].nil?
  #         @answers[answer.answer] = []
  #       end

  #       @answers[answer.answer] << { question: answer.question }
  #       points = answer.answer.to_f

  #       if points > 0
  #         totals += points
  #         counts += 1
  #         @total += points
  #         @count += 1
  #       end
  #     end
  #     
  #     age = nil
  #     gender = nil

  #     # turn this into member model method?
  #     survey.member.member_attributes.each do |attr|
  #       if attr[:name] == 'gender'
  #         gender = attr[:value]
  #       end
  #       if attr[:name] == 'birthday'
  #         dob = Date.strptime(attr[:value], '%m/%d/%Y')
  #         dob = Date.strptime(attr[:value], '%m/%d/%y') if dob.year < 100
  #         now = Time.now.utc.to_date
  #         age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  #       end
  #     end

  #     @surveys << { 
  #       id: survey[:id],
  #       placed: survey.order[:created_at],
  #       spent: survey.order[:amount],
  #       age: age,
  #       gender: gender,
  #       average: totals / counts.to_f,
  #     }
  #   end
  #   
  #   @answers.each do |k,v|
  #     @answers[k] = v.length
  #   end
  #   
  #   average = @total / @count.to_f
  #   average = 0 if average.nan?

  #   @ratings = {
  #     average: average,
  #     surveys: @surveys,
  #     answers: @answers,
  #   }

  #   render json: @ratings.to_json
  # end

  # }}}
  # {{{ def survey_member
  # def survey_member
  #   survey = MemberSurvey.find(params[:id])
  #   next_survey = MemberSurvey.select('id').where(store_id: params[:store_id]).where('member_surveys.id < ?', params[:id]).includes(:order).order('orders.created_at DESC').limit(1).first

  #   age = nil
  #   gender = nil

  #   survey.member.member_attributes.each do |attr|
  #     if attr[:name] == 'gender'
  #       gender = attr[:value]
  #     end
  #     if attr[:name] == 'birthday'
  #       dob = Date.strptime(attr[:value], '%m/%d/%Y')
  #       dob = Date.strptime(attr[:value], '%m/%d/%y') if dob.year < 100
  #       now = Time.now.utc.to_date
  #       age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  #     end
  #   end

  #   @results = {
  #     categories: [],
  #     ratings: [],
  #   }

  #   o_total = 0
  #   o_count = 0

  #   survey.member_survey_answers.each do |ans|
  #     product = ans.product
  #     category = ans.survey_question.survey_question_category
  #     points = ans.answer.to_f
  #     if points > 0
  #       unless product.nil?
  #         found = false
  #         @results[:ratings].each do |rating|
  #           if rating[:name] == product.name
  #             found = true
  #             rating[:total] += points
  #             rating[:count] += 1
  #             break
  #           end
  #         end
  #         unless found
  #           @results[:ratings] << { name: product.name, total: points, count: 1 }
  #         end
  #       end
  #       unless category.nil?
  #         total = 0
  #         count = 0
  #         found = false
  #         @results[:categories].each do |cat|
  #           if cat[:name] == category.name
  #             found = true
  #             cat[:total] += points
  #             cat[:count] += 1
  #             break
  #           end
  #         end
  #         unless found
  #           total += points
  #           count += 1
  #           @results[:categories] << { name: category.name, total: total, count: count }
  #         end
  #       end

  #       o_total += points
  #       o_count += 1
  #     end
  #   end

  #   @results[:categories] << { name: 'Overall', total: o_total, count: o_count }

  #   next_id = nil
  #   next_id = next_survey[:id] unless next_survey.nil?

  #   @member = {
  #     id: survey.member[:id],
  #     age: age,
  #     gender: gender,
  #     survey: {
  #       id: survey[:id],
  #       comments: survey[:comments],
  #       results: @results,
  #       placed: survey.order[:created_at],
  #       spent: survey.order[:amount],
  #       next_id: next_id,
  #     },
  #   }

  #   render json: @member.to_json
  # end

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
  # {{{ old
  # def surveys
  #   member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('orders.created_at DESC')

  #   @results = {
  #     categories: [
  #       { 
  #         name: 'Overall', 
  #         total: {
  #           one: 0, 
  #           seven: 0, 
  #           thirty: 0, 
  #           all: 0, 
  #         },
  #         data: {
  #           one: [],
  #           seven: [],
  #           thirty: [],
  #           all: [],
  #         },
  #         count: {
  #           one: 0, 
  #           seven: 0, 
  #           thirty: 0, 
  #           all: 0, 
  #         },
  #       },
  #     ],
  #     ratings: [],
  #     total: {
  #       surveys: member_surveys.count,
  #       members: 0,
  #     },
  #   }

  #   members = []

  #   now = Time.now
  #   yesterday = now - 1.day
  #   past_seven = now - 7.day
  #   past_thirty = now - 30.day

  #   o_total = 0
  #   o_count = 0

  #   member_surveys.each do |survey|
  #     unless members.include? survey.member_id
  #       members << survey.member_id
  #     end
  #     survey.member_survey_answers.each do |ans|
  #       product = ans.product
  #       category = ans.survey_question.survey_question_category
  #       category = category.parent unless category.parent.nil?
  #       points = ans.answer.to_f
  #       if points > 0
  #         unless product.nil?
  #           found = false
  #           @results[:ratings].each do |rating|
  #             if rating[:name] == product.name
  #               found = true
  #               rating[:total][:all] += points
  #               rating[:count][:all] += 1
  #               break
  #             end
  #           end
  #           unless found
  #             @results[:ratings] << { 
  #               name: product.name,
  #               total: {
  #                 one: 0,
  #                 seven: 0,
  #                 thirty: 0,
  #                 all: points,
  #               },
  #               count: {
  #                 one: 0,
  #                 seven: 0,
  #                 thirty: 0,
  #                 all: 1,
  #               },
  #             }
  #           end
  #         end
  #         unless category.nil?
  #           total = 0
  #           count = 0
  #           found = false
  #           @results[:categories].each do |cat|
  #             if cat[:name] == category.name
  #               found = true
  #               cat[:total][:all] += points
  #               cat[:count][:all] += 1
  #               cat[:data][:all] << { time: survey.order.created_at, points: points }
  #               break
  #             end
  #           end
  #           unless found
  #             total += points
  #             count += 1
  #             @results[:categories] << { 
  #               name: category.name, 
  #               total: {
  #                 one: 0,
  #                 seven: 0,
  #                 thirty: 0,
  #                 all: total, 
  #               },
  #               data: {
  #                 one: [],
  #                 seven: [],
  #                 thirty: [],
  #                 all: [
  #                   { time: survey.order.created_at, points: points },
  #                 ],
  #               },
  #               count: {
  #                 one: 0,
  #                 seven: 0,
  #                 thirty: 0,
  #                 all: count,
  #               },
  #             }
  #           end
  #         end

  #         o_total += points
  #         o_count += 1
  #         @results[:categories][0][:data][:all] << { time: survey.order.created_at, points: points }
  #       end
  #     end

  #     @results[:categories][0][:total][:all] = o_total; 
  #     @results[:categories][0][:count][:all] = o_count; 

  #     if survey.order.created_at >= yesterday
  #       @results[:ratings].each do |rating| 
  #         rating[:total][:one] = rating[:total][:all] 
  #         rating[:count][:one] = rating[:count][:all] 
  #       end
  #       @results[:categories].each do |category| 
  #         category[:total][:one] = category[:total][:all] 
  #         category[:count][:one] = category[:count][:all] 
  #         category[:data][:one] = category[:data][:all] 
  #       end
  #     end
  #     if survey.order.created_at >= past_seven
  #       @results[:ratings].each do |rating| 
  #         rating[:total][:seven] = rating[:total][:all] 
  #         rating[:count][:seven] = rating[:count][:all] 
  #       end
  #       @results[:categories].each do |category| 
  #         category[:total][:seven] = category[:total][:all] 
  #         category[:count][:seven] = category[:count][:all] 
  #         category[:data][:seven] = category[:data][:all] 
  #       end
  #     end
  #     if survey.order.created_at >= past_thirty
  #       @results[:ratings].each do |rating| 
  #         rating[:total][:thirty] = rating[:total][:all] 
  #         rating[:count][:thirty] = rating[:count][:all] 
  #       end
  #       @results[:categories].each do |category| 
  #         category[:total][:thirty] = category[:total][:all] 
  #         category[:count][:thirty] = category[:count][:all] 
  #         category[:data][:thirty] = category[:data][:all] 
  #       end
  #     end
  #   end

  #   @results[:total][:members] = members.length

  #   render json: @results.to_json
  # end

  # }}}
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
