class Reply < TableEntry
  attr_accessor :question_id, :parent_id, :replier_id, :body
  def initialize(options)
    @id, @question_id, @parent_id, @replier_id, @body = options.values_at('id',
      'question_id', 'parent_id', 'replier_id', 'body')
  end

  def self.find_by_question_id(question_id)
    options = self.select_query_id('question_id', question_id)
    options.map {|question| Reply.new(question)}

  end
  def self.find_by_user_id replier_id
    options = self.select_query_id('replier_id', replier_id)
    options.map {|question| Reply.new(question)}
  end
  def author
    User.find_by_id(@replier_id)
  end
  def question
    Question.find_by_question_id(@question_id)
  end
  def parent_reply
    Reply.find_by_id(@parent_id)
  end
  def child_replies
    options = QuestionsDB.instance.execute(<<-SQL, @id)
    SELECT
      *
    FROM
      question_replies
    WHERE
      parent_id = ?
    SQL
    options.map {|reply| Reply.new(reply)}
  end
end
