require 'rails_helper'

describe PartnerApprovalService do
  describe '#call' do
    subject { described_class.new(partner: partner).call }
    let(:partner) { partners_partner.partner }
    let(:partners_partner) { create(:partners_partner, partner_status: partner_status) }
    let(:partner_status) { 'pending' }

    before do
      partner.awaiting_review!
    end

    context 'when the arguments are incorrect' do
      context 'because the partner is not awaiting_review' do
        before do
          partner.invited!
        end

        it 'should return the PartnerApprovalService object with an error' do
          result = subject

          expect(result).to be_a_kind_of(PartnerApprovalService)
          expect(result.errors[:partner]).to eq(["is not waiting for approval"])
        end
      end
    end

    context 'when the arguments are correct' do
      it 'should have no errors' do
        expect(subject.errors).to be_empty
      end

      it 'should change the partner status to approved' do
        expect { subject }.to change { partner.reload.approved? }.from(false).to(true)
        expect { subject }.to change { partners_partner.reload.partner_status }.to('approval')
      end

      context 'but a unexpected error occured during the save' do
        let(:error_message) { 'boom' }

        context 'for partner approval' do
          before do
            allow(partner).to receive(:approved!).and_raise(error_message)
          end

          it 'should have an error with the raised error' do
            expect(subject.errors[:base]).to eq([error_message])
          end

          it 'should not change the partner status to approved' do
            expect { subject }.not_to change { partner.reload.approved? }
            expect { subject }.not_to change { partners_partner.reload.partner_status }
          end
        end
      end
    end
  end
end

