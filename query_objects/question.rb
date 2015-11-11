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

  def followers
    Follow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    Follow.most_followed_questions(n)
  end

  def likers
    Like.likers_for_question_id(@id)
  end

  def num_likes
    Like.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    Like.most_liked_questions(n)
  end

end
