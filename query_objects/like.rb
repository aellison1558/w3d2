class Like < TableEntry
  attr_accessor :question_id, :liker_id
  def initialize(options)
    @id, @question_id, @liker_id = options.values_at('id',
      'question_id', 'liker_id')
  end

  def self.likers_for_question_id(question_id)
    options = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        liker_id
      FROM
        question_likes
      WHERE
        question_id = ?
      SQL
      options.map {|hash| User.find_by_id(hash['liker_id'])}
  end

  def self.num_likes_for_question_id(question_id)
    options = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL

    options.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    options = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        question_id
      FROM
        question_likes
      WHERE
        liker_id = ?
      SQL
      options.map {|hash| Question.find_by_id(hash['question_id'])}
  end

  def self.most_liked_questions(n)
    options = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_likes
      GROUP BY
        question_id
      ORDER BY
        COUNT(*)
      LIMIT
        ?
    SQL

    options.map {|hash| Question.find_by_id(hash['question_id'])}
  end
end
