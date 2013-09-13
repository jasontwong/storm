class SurveyQuestion < ActiveRecord::Base
  attr_accessible :answer_meta, :answer_type, :question, :company_id, :active, :dynamic, :dynamic_meta

  belongs_to :company, inverse_of: :survey_questions
  belongs_to :survey_question_category, inverse_of: :survey_questions
  has_many :member_survey_answers, inverse_of: :survey_question
  has_and_belongs_to_many :products
  has_and_belongs_to_many :surveys

  serialize :answer_meta, Hash
  serialize :dynamic_meta, Array

  validates :answer_type, presence: true
  validates :question, presence: true
  validates :company_id, presence: true
  validates :active, :inclusion => { :in => [true, false] }
  validates :dynamic, :inclusion => { :in => [true, false] }

  def build_question(code)
    question = self.question

    if self.dynamic
      details = OrderDetail.where(code_id: code.id).where('product_id IS NOT NULL').order('price DESC')
      vars = []
      self.dynamic_meta.each do |meta|
        if meta.has_key? :product_ids
          details.each do |detail|
            if meta[:product_ids].include? detail.product_id
              vars << detail.product.name 
              break
            end
          end
        end
      end
      
      if vars.count == self.dynamic_meta.count
        question = self.question % vars
      else
        question = nil
      end
    end

    return question

  end

end
