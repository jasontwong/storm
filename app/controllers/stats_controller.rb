class StatsController < ApplicationController
  # {{{ def store_ratings
  def store_ratings
    member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('created_at DESC')

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
        points = answer.answer.to_i

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
          gender = attr[:value][0].upcase
        end
        if attr[:name] == 'birthday'
          dob = Date.strptime(attr[:value], '%m/%d/%Y')
          now = Time.now.utc.to_date
          age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
        end
      end

      # last_week = Time.now - 7.days

      @surveys << { 
        id: survey[:id],
        placed: survey.order[:created_at],
        # placed: Time.at(last_week + rand * (Time.now.to_f - last_week.to_f)),
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

    age = nil
    gender = nil

    survey.member.member_attributes.each do |attr|
      if attr[:name] == 'gender'
        gender = attr[:value][0].upcase
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
      category = ans.survey_question.survey_question_category
      points = ans.answer.to_i
      if points > 0
        unless category.nil?
          total = 0
          count = 0
          found = false
          @results[:categories].each do |cat|
            if cat[:name] == category.name
              total = cat[:total]
              count = cat[:count]
              break
            end
          end
          total += points
          count += 1
          @results[:categories] << { name: category.name, total: total, count: count }
        end

        o_total += points
        o_count += 1
      end
    end

    @results[:categories] << { name: 'Overall', total: o_total, count: o_count }

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
      },
    }

    render json: @member.to_json
  end

  # }}}
end
