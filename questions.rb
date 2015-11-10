def reload
  load __FILE__
end

require 'sqlite3'
require 'singleton'
class QuestionsDB < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end
class TableEntry
  TABLENAMES = {
    'Question' => 'questions',
    'User' => 'users',
    'Follow' => 'question_follows',
    'Like' => 'question_likes',
    'Reply' => 'question_replies'
  }
  attr_accessor :id
  def self.find_by_id id
    options = QuestionsDB.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self::TABLENAMES[self.to_s]}
    WHERE
      id = ?
    SQL
    return nil if options.first.nil?
    self.new(options.first)
  end

  def self.select_query_id(column, id)
    result = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self::TABLENAMES[self.to_s]}
      WHERE
        #{column} = ?
    SQL
    result
  end
end

class User < TableEntry
  attr_accessor :fname, :lname
  def initialize(options)
    @id, @fname, @lname = options.values_at('id', 'fname', 'lname')
  end

  def self.find_by_name(fname, lname)
    options = QuestionsDB.instance.execute(<<-SQL, lname, fname)
      SELECT
        *
      FROM
        users
      WHERE
        lname = ? AND fname = ?
    SQL
    raise 'No such person' if options.first.nil?
    options.map{|user| self.new(user)}
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end
  def authored_replies
    Reply.find_by_user_id(@id)
  end
end

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

class Follow < TableEntry
  attr_accessor :question_id, :follower_id
  def initialize(options)
    @id, @question_id, @follower_id = options.values_at('id',
      'question_id', 'follower_id')
  end
end

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

class Like < TableEntry
  attr_accessor :question_id, :liker_id
  def initialize(options)
    @id, @question_id, @liker_id = options.values_at('id',
      'question_id', 'liker_id')
  end
end
