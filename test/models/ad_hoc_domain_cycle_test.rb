require 'test_helper'

class AdHocDomainCycleTest < ActiveSupport::TestCase
  setup do
    @ad_hoc_domain_cycle = FactoryBot.create(:ad_hoc_domain_cycle)
  end

  test "must have a name" do
    @ad_hoc_domain_cycle.name = ""
    assert_not @ad_hoc_domain_cycle.valid?
  end

  test "must have a start date" do
    @ad_hoc_domain_cycle.starts_on = nil
    assert_not @ad_hoc_domain_cycle.valid?
  end

  test "must have an end date" do
    @ad_hoc_domain_cycle.exclusive_end_date = nil
    assert_not @ad_hoc_domain_cycle.valid?
  end

  test "end date can be assigned inclusively" do
    @ad_hoc_domain_cycle.ends_on = nil
    assert_not @ad_hoc_domain_cycle.valid?
    new_ends_on = Date.today + 14.days
    @ad_hoc_domain_cycle.ends_on = new_ends_on
    assert_equal new_ends_on + 1.day, @ad_hoc_domain_cycle.exclusive_end_date
  end

  test "duration must be non-negative" do
    ahdc = FactoryBot.build(
      :ad_hoc_domain_cycle,
      starts_on: Date.today,
      exclusive_end_date: Date.yesterday)
    assert_not ahdc.valid?
  end

  test "duration must be strictly positive" do
    ahdc = FactoryBot.build(
      :ad_hoc_domain_cycle,
      starts_on: Date.today,
      exclusive_end_date: Date.today)
    assert_not ahdc.valid?
  end

  test "must belong to a domain" do
    @ad_hoc_domain_cycle.ad_hoc_domain = nil
    assert_not @ad_hoc_domain_cycle.valid?
  end

  test "deleting cycle nullifies default setting in parent" do
    ahd = FactoryBot.create(:ad_hoc_domain)
    ahdc = FactoryBot.create(:ad_hoc_domain_cycle, ad_hoc_domain: ahd)
    ahd.default_cycle = ahdc
    ahd.save
    assert_equal ahdc, ahd.default_cycle
    ahdc.destroy
    ahd.reload
    assert_nil ahd.default_cycle
  end

  test "deleting the parent domain deletes the cycle" do
    ahd = FactoryBot.create(:ad_hoc_domain)
    ahdc = FactoryBot.create(:ad_hoc_domain_cycle, ad_hoc_domain: ahd)
    assert_difference('AdHocDomainCycle.count', -1) do
      ahd.destroy
    end
  end

  test "can have subjects" do
    ahds = FactoryBot.create(
      :ad_hoc_domain_subject,
      ad_hoc_domain_cycle: @ad_hoc_domain_cycle)
    assert ahds.valid?
  end

  test "deleting cycle deletes the subject records" do
    ahdc = FactoryBot.create(:ad_hoc_domain_cycle)
    ahds = FactoryBot.create(
      :ad_hoc_domain_subject,
      ad_hoc_domain_cycle: ahdc)
    assert ahds.valid?
    assert_difference('AdHocDomainSubject.count', -1) do
      ahdc.destroy
    end
  end

  test "can be linked to multiple subjects" do
    subject1 = FactoryBot.create(:subject)
    subject2 = FactoryBot.create(:subject)
    #
    #  Something intriguing which I discovered entirely by accident.
    #  I originally had a HABTM relationship between AdHocDomain and
    #  Subject Element, then changed it to an explicit intermediate
    #  model.  Nonetheless, the trick of <<ing a new element still
    #  seems to work.  Clever.
    #
    @ad_hoc_domain_cycle.subjects << subject1
    @ad_hoc_domain_cycle.subjects << subject2
    assert_equal 2, @ad_hoc_domain_cycle.subjects.count
    assert_equal 2, @ad_hoc_domain_cycle.ad_hoc_domain_subjects.count
    assert subject1.ad_hoc_domain_cycles.include?(@ad_hoc_domain_cycle)
    #
    #  Deleting the AdHocDomainCycle deletes its AdHocDomainSubjects but not
    #  the subjects.
    #
    assert_difference('AdHocDomainSubject.count', -2) do
      @ad_hoc_domain_cycle.destroy
      subject1.reload
      subject2.reload
      assert_not_nil subject1.element
      assert_not_nil subject2.element
    end
  end

  test "can get all records for one member of staff" do
    assert @ad_hoc_domain_cycle.respond_to? :peers_of
    #
    #  See that it works
    #
    staffs = []
    2.times do
      staffs << FactoryBot.create(:staff)
    end

    subjects = []
    3.times do
      subjects << FactoryBot.create(:subject)
    end

    ahd_staffs = []
    subjects.each do |subject|
      ahdsu = FactoryBot.create(
        :ad_hoc_domain_subject,
        ad_hoc_domain_cycle: @ad_hoc_domain_cycle,
        subject: subject)
      staffs.each do |staff|
        ahd_staffs << FactoryBot.create(
          :ad_hoc_domain_staff,
          ad_hoc_domain_subject: ahdsu,
          staff: staff)
      end
    end
    ahd_staffs.each do |ahdst|
      assert_equal 3, @ad_hoc_domain_cycle.peers_of(ahdst).count
    end
  end

  test "implements position of" do
    assert @ad_hoc_domain_cycle.respond_to? :position_of
  end

end
