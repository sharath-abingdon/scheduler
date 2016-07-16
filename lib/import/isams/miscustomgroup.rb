class ISAMS_CustomgroupCategory
  SELECTOR = "PupilManager CustomGroupCategory Category"
  REQUIRED_FIELDS = [
    IsamsField["Id",         :isams_id,    :attribute, :integer],
    IsamsField["Name",       :name,        :data,      :string]
  ]

  include Creator

  def initialize(entry)
  end

  def self.construct(loader, isams_data)
    #
    #  For convenience, we return ourselves as a hash.
    #
    categories = self.slurp(isams_data)
    category_hash = Hash.new
    categories.each do |category|
      category_hash[category.isams_id] = category
    end
    category_hash
  end
end

class ISAMS_CustomgroupMembershipItem
  SELECTOR = "PupilManager CustomPupilGroupMembershipItems CustomPupilGroupMembershipItem"
  REQUIRED_FIELDS = [
    IsamsField["Id",            :isams_id,    :attribute, :integer],
    IsamsField["PupilID",       :pupil_id,    :attribute, :integer],
    IsamsField["CustomGroupId", :group_id,    :data,      :integer]
  ]

  include Creator

  def initialize(entry)
  end

  def self.construct(loader, isams_data, group_hash)
    memberships = self.slurp(isams_data)
    #
    #  Now add each of our pupils to the corresponding group.
    #
    memberships.each do |membership|
      pupil = loader.pupil_hash[membership.pupil_id]
      group = group_hash[membership.group_id]
      if pupil && group
        group.add_pupil(pupil)
      end
    end
  end
end

class MIS_Customgroup
  SELECTOR = "PupilManager CustomPupilGroups CustomPupilGroup"
  REQUIRED_FIELDS = [
    IsamsField["Id",         :isams_id,    :attribute, :integer],
    IsamsField["AuthorID",   :author_id,   :attribute, :integer],
    IsamsField["Name",       :isams_name,  :data,      :string],
    IsamsField["CategoryId", :category_id, :data,      :integer],
    IsamsField["Shared",     :shared_flag, :data,      :integer],
    IsamsField["ExpiryDate", :expiry_date, :data,      :string],
    IsamsField["Author",     :user_code,   :data,      :string]
  ]

  include Creator

  attr_reader :datasource_id, :era, :owner, :shared

  def initialize(entry)
    @pupils = Array.new
    @current = true
    @make_public = false
    @datasource_id = @@primary_datasource_id
    #
    #  TODO Work out why we have both of these next two and get rid
    #  of one.
    #
    @era = Setting.perpetual_era
    @era_id = @era.id
    @owner = nil
    super
  end

  def source_id_str
    @isams_id
  end

  def adjust
    @shared = (@shared_flag == 1)
    #
    #  The staff record definitely should exist (modulo inconsistent
    #  data in iSAMS) but the user record may well not.  It doesn't
    #  exist until the corresponding member of staff logs in to
    #  Scheduler.  Until then we don't load this group.
    #
    @owner_staff = staff_by_user_code[self.user_code]
    if @owner_staff && @owner_staff.dbrecord
      @owner = @owner_staff.dbrecord.corresponding_user
      if @owner
        @owner_id = @owner.id
        #
        #  Now we know who the owner is, we can decide whether or
        #  not actually to make this one public.
        #
        #  Its public iff the owner has permission *and* it has
        #  come from iSAMS as shared.
        #
        @make_public = @owner.public_groups && @shared
      end
    end
  end

  def wanted
#    if @owner == nil
#      puts "Dropping custom group #{self.name} for lack of an owner."
#      puts "owner_id = #{self.owner_id}."
#      puts "user_code = #{self.user_code}."
#      puts "Would be #{@owner_staff ? @owner_staff.name : "Unknown"}."
#    end
    @owner != nil
  end

  def add_pupil(pupil)
    @pupils << pupil
  end

  def note_category(category)
    @category = category
  end

  def name
    if @category
      "#{@isams_name} (#{@category.name})"
    else
      "#{@isams_name}"
    end
  end

  def loader
    self.class.loader
  end

  def staff_by_user_code
    self.class.staff_by_user_code
  end

  def report
    puts "Custom group #{self.name}"
    puts "  #{@pupils.size} pupils."
    puts "  Owned by #{@owner.name}"
  end

  def self.construct(loader, isams_data)
    @loader = loader
    #
    #  Matching groups up with members of staff is actually quite
    #  tricky.  The owner id which they contain points to a user
    #  record instead of to a staff record.
    #
    #  We could go Group => User => Staff
    #
    #  using first the owner id, and then the SchoolId from the user
    #  record, but for now at least, said SchoolId appears in the
    #  group record (albeit marked as legacy) and it's called
    #  Author.  Go direct for now.  May need to indirect later.
    #
    @staff_by_user_code = Hash.new
    @loader.staff.each do |staff|
      @staff_by_user_code[staff.user_code] = staff
    end
    @categories = ISAMS_CustomgroupCategory.construct(loader, isams_data)
    @groups = self.slurp(isams_data)
    @groups.each do |group|
      group.note_category(@categories[group.category_id])
    end
    @group_hash = Hash.new
    @groups.each do |group|
      @group_hash[group.isams_id] = group
    end
    ISAMS_CustomgroupMembershipItem.construct(loader, isams_data, @group_hash)
    @groups
  end

  def self.loader
    @loader
  end

  def self.staff_by_user_code
    @staff_by_user_code
  end

end


