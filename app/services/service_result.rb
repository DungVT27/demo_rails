class ServiceResult
  attr_reader :record, :errors

  def initialize(success, record = nil, errors = [])
    @success = success
    @record = record
    @errors = errors
  end

  def success?
    @success
  end
end
