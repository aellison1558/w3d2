class Follow < TableEntry
  attr_accessor :question_id, :follower_id
  def initialize(options)
    @id, @question_id, @follower_id = options.values_at('id',
      'question_id', 'follower_id')
  end

  def self.followers_for_question_id(question_id)
    options = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        follower_id
      FROM
        question_follows
      WHERE
        question_id = ?
      SQL
      options.map {|hash| User.find_by_id(hash['follower_id'])}
  end
  def self.followed_questions_for_user_id(user_id)
    options = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        question_follows
      WHERE
        follower_id = ?
      SQL
      options.map {|hash| Question.find_by_id(hash['question_id'])}
  end
  def self.most_followed_questions(n)
    options = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    options.map {|hash| Question.find_by_id(hash['question_id'])}
  end
end
