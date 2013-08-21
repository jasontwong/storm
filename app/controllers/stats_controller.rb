class StatsController < ApplicationController
  def store_ratings
    member_surveys = MemberSurvey.where(store_id: params[:store_id]).includes(:member_survey_answers, :order, :member => :member_attributes).order('created_at DESC')

    if params[:num_days] && !member_surveys.nil?
      if params[:num_days] == 'today'
        member_surveys = member_surveys.where('created_at > ?', Time.now.strftime('%F'))
      else
        member_surveys = member_surveys.where('created_at > ?', Time.now.utc - params[:num_days].to_i.days)
      end
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
          gender = attr[:value].downcase
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

    @ratings = {
      average: @total / @count.to_f,
      surveys: @surveys,
      answers: @answers,
    }

    render json: @ratings.to_json
  end

  def survey_member
    survey = MemberSurvey.find(params[:id])
    member = survey.member
    surveys = MemberSurvey.where(member_id: member[:id], store_id: survey[:store_id]).includes(:member_survey_answers).order('created_at DESC').limit(5)

    @total = 0
    @count = 0
    @surveys = []

    surveys.each do |survey|
      totals = 0
      counts = 0
      survey.member_survey_answers.each do |answer|
        points = answer.answer.to_i

        if points > 0
          totals += points
          counts += 1
          @total += points
          @count += 1
        end
      end
      
      @surveys << { 
        average: totals / counts.to_f,
      }
    end

    age = nil

    member.member_attributes.each do |attr|
      if attr[:name] == 'birthday'
        dob = Date.strptime(attr[:value], '%m/%d/%Y')
        now = Time.now.utc.to_date
        age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      end
    end

    @member = {
      id: member[:id],
      age: age,
      spent: 0,
      average: 0,
      survey: {
        id: survey[:id],
        comments: survey[:comments],
        results: survey.member_survey_answers.collect { |ans| { q: ans.question, a: ans.answer } },
        placed: survey.order[:created_at],
        spent: survey.order[:amount],
      },
      surveys: @surveys,
    }

    render json: @member.to_json
  end

end
