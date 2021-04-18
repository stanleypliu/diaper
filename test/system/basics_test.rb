RSpec.describe "Partner management", type: :system, js: true do
  before do
    sign_in(@user)
  end
  let!(:url_prefix) { "/#{@organization.to_param}" }

  describe 'approving a partner that is awaiting approval' do
    let!(:partner_awaiting_approval) { create(:partner, :awaiting_review) }

    before do
      expect(partner_awaiting_approval.profile.partner_status).not_to eq('approval')
    end

    context 'when the approval succeeds' do
      it 'should approve the partner' do
        visit url_prefix + "/partners"
        magic_test
      end
    end
  end
end

