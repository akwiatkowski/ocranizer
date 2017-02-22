module Ocranizer::Decorators::Sort
  def >(other)
    (self <=> other) == 1
  end

  def <(other)
    (self <=> other) == -1
  end

  def >=(other)
    (self <=> other) == 1 || (self <=> other) == 0
  end

  def <=(other)
    (self <=> other) == -1 || (self <=> other) == 0
  end
end
