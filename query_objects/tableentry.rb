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

    options = QuestionsDB.instance.execute(<<-SQL)
    INSERT INTO users(#{attr_names})
    VALUES(#{attr_values})
    SQL
    self.id = QuestionsDB.instance.last_insert_row_id
  end

  def attr_names
    attributes = self.instance_variables[1..-1]
    attributes.map {|a| a.to_s[1..-1]}.join(", ")
  end

  def attr_values
    attributes = self.instance_variables[1..-1]
    attr_values = attributes.map {|name| self.send(name.to_s[1..-1])}
    attr_values = attr_values.map do |val|
       val.is_a?(String) ? val = "'#{val}'" : val
    end.join(", ")
  end

  def self.all
    options = QuestionsDB.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self::TABLENAMES[self.to_s]}
    SQL
    return nil if options.first.nil?
    options.map {|object| self.new(object)}
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

  def self.select_query_id(options)
    where = options.keys.map do |key|
      "#{key} = ?"
    end.join(" AND ")
    what = options.values.join(", ")
    result = QuestionsDB.instance.execute(<<-SQL, what)
      SELECT
        *
      FROM
        #{self::TABLENAMES[self.to_s]}
      WHERE
        #{where}
    SQL
    result
  end
  def method_missing(method_name, *args)
    p method_name, args
    if method_name.to_s.start_with?("find_by_")
      method_name = method_name.to_s
      method_name = method_name.split(_)[2..-1]
      options = {}
      method_name.times do |idx|
        options[method_name[idx]] = args[idx]
      end
      self.select_query_id(options)
    else
      super
    end
  end
end
