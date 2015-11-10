class Follow < TableEntry
  attr_accessor :question_id, :follower_id
  def initialize(options)
    @id, @question_id, @follower_id = options.values_at('id',
      'question_id', 'follower_id')
  end
end
