class StatsController < ApplicationController
  # {{{ def store_ratings
  def store_ratings
    member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('orders.created_at DESC')

    if params[:offset] && !member_surveys.nil?
      member_surveys = member_surveys.offset(params[:offset])
    end

    if params[:limit] && !member_surveys.nil?
      member_surveys = member_surveys.limit(params[:limit])
    end

    @answers = {}
    @surveys = []
    @total = 0
    @count = 0
    
    member_surveys.each do |survey|
      totals = 0
      counts = 0
      survey.member_survey_answers.each do |answer|
        if @answers[answer.answer].nil?
          @answers[answer.answer] = []
        end

        @answers[answer.answer] << { question: answer.question }
        points = answer.answer.to_f

        if points > 0
          totals += points
          counts += 1
          @total += points
          @count += 1
        end
      end
      
      age = nil
      gender = nil

      # turn this into member model method?
      survey.member.member_attributes.each do |attr|
        if attr[:name] == 'gender'
          gender = attr[:value]
        end
        if attr[:name] == 'birthday'
          dob = Date.strptime(attr[:value], '%m/%d/%Y')
          now = Time.now.utc.to_date
          age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
        end
      end

      @surveys << { 
        id: survey[:id],
        placed: survey.order[:created_at],
        spent: survey.order[:amount],
        age: age,
        gender: gender,
        average: totals / counts.to_f,
      }
    end
    
    @answers.each do |k,v|
      @answers[k] = v.length
    end
    
    average = @total / @count.to_f
    average = 0 if average.nan?

    @ratings = {
      average: average,
      surveys: @surveys,
      answers: @answers,
    }

    render json: @ratings.to_json
  end

  # }}}
  # {{{ def survey_member
  def survey_member
    survey = MemberSurvey.find(params[:id])
    next_survey = MemberSurvey.select('id').where(store_id: params[:store_id]).where('member_surveys.id < ?', params[:id]).includes(:order).order('orders.created_at DESC').limit(1).first

    age = nil
    gender = nil

    survey.member.member_attributes.each do |attr|
      if attr[:name] == 'gender'
        gender = attr[:value]
      end
      if attr[:name] == 'birthday'
        dob = Date.strptime(attr[:value], '%m/%d/%Y')
        now = Time.now.utc.to_date
        age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      end
    end

    @results = {
      categories: [],
      ratings: [],
    }

    o_total = 0
    o_count = 0

    survey.member_survey_answers.each do |ans|
      product = ans.product
      category = ans.survey_question.survey_question_category
      points = ans.answer.to_f
      if points > 0
        unless product.nil?
          found = false
          @results[:ratings].each do |rating|
            if rating[:name] == product.name
              found = true
              rating[:total] += points
              rating[:count] += 1
              break
            end
          end
          unless found
            @results[:ratings] << { name: product.name, total: points, count: 1 }
          end
        end
        unless category.nil?
          total = 0
          count = 0
          found = false
          @results[:categories].each do |cat|
            if cat[:name] == category.name
              found = true
              cat[:total] += points
              cat[:count] += 1
              break
            end
          end
          unless found
            total += points
            count += 1
            @results[:categories] << { name: category.name, total: total, count: count }
          end
        end

        o_total += points
        o_count += 1
      end
    end

    @results[:categories] << { name: 'Overall', total: o_total, count: o_count }

    next_id = nil
    next_id = next_survey[:id] unless next_survey.nil?

    @member = {
      id: survey.member[:id],
      age: age,
      gender: gender,
      survey: {
        id: survey[:id],
        comments: survey[:comments],
        results: @results,
        placed: survey.order[:created_at],
        spent: survey.order[:amount],
        next_id: next_id,
      },
    }

    render json: @member.to_json
  end

  # }}}
  # {{{ def surveys
  def surveys
    member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('orders.created_at DESC')

    @results = {
      categories: [
        { 
          name: 'Overall', 
          total: {
            one: 0, 
            seven: 0, 
            thirty: 0, 
            all: 0, 
          },
          count: {
            one: 0, 
            seven: 0, 
            thirty: 0, 
            all: 0, 
          },
        },
      ],
      ratings: [],
      total: {
        surveys: member_surveys.count,
        members: 0,
      },
    }

    members = []

    now = Time.now
    yesterday = now - 1.day
    past_seven = now - 7.day
    past_thirty = now - 30.day

    o_total = 0
    o_count = 0

    member_surveys.each do |survey|
      unless members.include? survey.member_id
        members << survey.member_id
      end
      survey.member_survey_answers.each do |ans|
        product = ans.product
        category = ans.survey_question.survey_question_category
        category = category.parent unless category.parent.nil?
        points = ans.answer.to_f
        if points > 0
          unless product.nil?
            found = false
            @results[:ratings].each do |rating|
              if rating[:name] == product.name
                found = true
                rating[:total][:all] += points
                rating[:count][:all] += 1
                break
              end
            end
            unless found
              @results[:ratings] << { 
                name: product.name,
                total: {
                  one: 0,
                  seven: 0,
                  thirty: 0,
                  all: points,
                },
                count: {
                  one: 0,
                  seven: 0,
                  thirty: 0,
                  all: 1,
                },
              }
            end
          end
          unless category.nil?
            total = 0
            count = 0
            found = false
            @results[:categories].each do |cat|
              if cat[:name] == category.name
                found = true
                cat[:total][:all] += points
                cat[:count][:all] += 1
                break
              end
            end
            unless found
              total += points
              count += 1
              @results[:categories] << { 
                name: category.name, 
                total: {
                  one: 0,
                  seven: 0,
                  thirty: 0,
                  all: total, 
                },
                count: {
                  one: 0,
                  seven: 0,
                  thirty: 0,
                  all: count,
                },
              }
            end
          end

          o_total += points
          o_count += 1
        end
      end

      @results[:categories][0] = { 
        name: 'Overall',
        total: {
          one: 0,
          seven: 0,
          thirty: 0,
          all: o_total,
        },
        count: {
          one: 0,
          seven: 0,
          thirty: 0,
          all: o_count,
        },
      }

      break if survey.order.created_at < past_thirty
      if survey.order.created_at >= yesterday
        @results[:ratings].each do |rating| 
          rating[:total][:one] = rating[:total][:all] 
          rating[:count][:one] = rating[:count][:all] 
        end
        @results[:categories].each do |category| 
          category[:total][:one] = category[:total][:all] 
          category[:count][:one] = category[:count][:all] 
        end
      end
      if survey.order.created_at >= past_seven
        @results[:ratings].each do |rating| 
          rating[:total][:seven] = rating[:total][:all] 
          rating[:count][:seven] = rating[:count][:all] 
        end
        @results[:categories].each do |category| 
          category[:total][:seven] = category[:total][:all] 
          category[:count][:seven] = category[:count][:all] 
        end
      end
      if survey.order.created_at >= past_thirty
        @results[:ratings].each do |rating| 
          rating[:total][:thirty] = rating[:total][:all] 
          rating[:count][:thirty] = rating[:count][:all] 
        end
        @results[:categories].each do |category| 
          category[:total][:thirty] = category[:total][:all] 
          category[:count][:thirty] = category[:count][:all] 
        end
      end
    end

    @results[:total][:members] = members.length

    render json: @results.to_json
  end

  # }}}
end
