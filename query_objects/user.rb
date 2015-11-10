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
  def followed_questions
    Follow.followed_questions_for_user_id(@id)
  end

end
