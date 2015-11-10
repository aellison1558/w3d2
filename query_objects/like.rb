class Like < TableEntry
  attr_accessor :question_id, :liker_id
  def initialize(options)
    @id, @question_id, @liker_id = options.values_at('id',
      'question_id', 'liker_id')
  end
end
