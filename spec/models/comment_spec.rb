require "rails_helper"

describe Comment do
  it "should get a short id" do
    c = create(:comment)

    expect(c.short_id).to match(/^\A[a-zA-Z0-9]{1,10}\z/)
  end

  describe "hat" do
    it "can't be worn if user doesn't have that hat" do
      comment = build(:comment, hat: build(:hat))
      comment.valid?
      expect(comment.errors[:hat]).to eq(['not wearable by user'])
    end

    it "can be one of the user's hats" do
      hat = create(:hat)
      user = hat.user
      comment = create(:comment, user: user, hat: hat)
      comment.valid?
      expect(comment.errors[:hat]).to be_empty
    end
  end

  it "validates the length of short_id" do
    comment = Comment.new(short_id: "01234567890")
    expect(comment).to_not be_valid
  end

  it "is not valid without a comment" do
    comment = Comment.new(comment: nil)
    expect(comment).to_not be_valid
  end

  it "validates the length of markeddown_comment" do
    comment = build(:comment, markeddown_comment: "a" * 16_777_216)
    expect(comment).to_not be_valid
  end

  describe ".recent_url_mentions" do
    subject { Comment.recent_url_mentions(url) }

    let(:url) { "https://lobste.rs" }
    let(:story) { build(:story, url: url) }

    context "with no recent comments containing story URL" do
      it "should return no mentions" do
        allow(Comment).to receive(:from_last_48_hours).and_return([])
        expect(subject).to be_empty
      end
    end

    context "with no url given" do
      let(:url) { nil }

      it "should return no mentions" do
        expect(subject).to be_empty
      end
    end

    context "with recent comments containing story URL" do
      let!(:comment1) { create(:comment, comment: "This is a comment with #{url}") }
      let!(:comment2) { create(:comment, comment: "This is a second comment with #{url}") }

      it "should return mentions" do
        expect(subject).to include(comment1, comment2)
      end
    end
  end
end
