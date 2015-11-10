class Question < TableEntry
  attr_accessor :title, :body, :creator_id

  def initialize(options)
    @id, @title, @body, @creator_id = options.values_at('id',
      'title', 'body', 'creator_id')
  end

  def self.find_by_author_id(author_id)
    options = QuestionsDB.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        creator_id = ?
    SQL
    options.map {|question| Question.new(question)}
  end
  def author
    User.find_by_id(@creator_id)
  end
  def replies
    Reply.find_by_question_id(@id)
  end
end
