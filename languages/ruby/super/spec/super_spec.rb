RSpec.describe Super::Super, type: :lib do

  it "has a version number" do
    expect(Super::VERSION).not_to be nil
  end

  describe ".initialize" do
    subject { described_class.new }

    it "sets var as an empty hash" do
      expect(subject.instance_variable_get(:@var)).to eq({})
    end

    it "has a getter" do
      expect(subject.var).to eq({})
    end
  end
end
