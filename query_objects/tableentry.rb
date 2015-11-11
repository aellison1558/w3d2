class TableEntry
  TABLENAMES = {
    'Question' => 'questions',
    'User' => 'users',
    'Follow' => 'question_follows',
    'Like' => 'question_likes',
    'Reply' => 'question_replies'
  }
  attr_accessor :id
  def save()
    raise 'ID already exists' if self.id
    attributes = self.instance_variables[1..-1]
    attr_names = attributes.map {|a| a.to_s[1..-1]}.join(", ")
    attr_values = attributes.map {|name| self.send(name.to_s[1..-1])}
    attr_values = attr_values.map do |val|
       val.is_a?(String) ? val = "'#{val}'" : val
    end.join(", ")
    p attr_names, attr_values, self.class::TABLENAMES[self.to_s]
    gets

    options = QuestionsDB.instance.execute(<<-SQL)
    INSERT INTO users(#{attr_names})
    VALUES(#{attr_values})
    SQL
    self.id = QuestionsDB.instance.last_insert_row_id
  end
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
