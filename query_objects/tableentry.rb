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
