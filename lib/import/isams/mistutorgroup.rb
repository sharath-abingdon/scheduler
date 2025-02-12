class MIS_Tutorgroup
  SELECTOR = "SchoolManager Forms Form"
  REQUIRED_FIELDS = [
    IsamsField["Id",        :isams_id, :attribute, :string],
    IsamsField["TutorId",   :tutor_id, :attribute, :integer],
    IsamsField["YearId",    :year_id,  :attribute, :integer],
    IsamsField["Form",      :name,     :data,      :string]
  ]

  include Creator

  attr_reader :datasource_id, :current

  def initialize(entry)
    @pupils = Array.new
    @staff = nil
    @current = true
    @datasource_id = @@primary_datasource_id
    #
    super
  end

  def source_id_str
    @isams_id
  end

  def adjust
  end

  def wanted
    @tutor_id && @year_id && local_wanted(@year_id)
  end

  def start_year
    local_effective_start_year(self.era, @year_id, 0)
  end

  #
  #  Return the yeargroup of this tutor group, in the form that Scheduler
  #  expects.  This is configurable, but generally corresponds to the
  #  years which the school naturally uses.  Thus for Abingdon we
  #  have:
  #
  #    1        NC 7
  #    2        NC 8
  #    3        NC 9
  #    4        NC 10
  #    5        NC 11
  #    6        NC 12
  #    7        NC 13
  #
  def yeargroup
    local_yeargroup(@year_id)
  end

  #
  #  Slightly messy, in that in iSAMS, tutor groups aren't directly
  #  linked to houses.  Have to get it from one of the pupil records.
  #
  #  This thus means that if a tutor group is empty, we have no way
  #  of knowing what house it belongs to.
  #
  def house
    if @pupils.empty?
      "Don't know"
    else
#      puts "Calculating house."
#      puts "First pupil is #{@pupils.first.name}"
#      puts "House is #{@pupils.first.house}"
      @pupils.first.house_name
    end
  end

  def link_to_house
    unless @pupils.empty?
      @house_rec = MIS_House.by_name(self.house)
      if @house_rec
        @house_rec.note_tutorgroup(self)
      else
        puts "Tutor group #{self.name} can't find house #{self.house}."
      end
    end
  end

  def self.construct(loader, isams_data)
    super
    tgs = self.slurp(isams_data.xml)
    tgs_hash = Hash.new
    tgs.each do |tg|
      tgs_hash[tg.isams_id] = tg
      staff = loader.staff_hash[tg.tutor_id]
      if staff
        tg.note_tutor(staff)
      end
    end
    #
    #  Now - can I populate them?
    #
    loader.pupils.each do |pupil|
      tg = tgs_hash[pupil.form_name]
      if tg
        tg.add_pupil(pupil)
      else
        #
        #  An unfortunate mis-feature of iSAMS is that pupils are linked
        #  to their tutor groups by name rather than by ID as they should
        #  be.  This means that you can end up with pupils with
        #  no matching tutor group if you aren't disciplined about
        #  entering your data.  It happens a lot at some schools,
        #  so log it only if we're not in quiet mode.
        #
        puts "Can't find tutor group \"#{pupil.form_name}\" for #{pupil.name}." unless loader.options.quiet
      end
    end
    tgs.each do |tg|
      puts "Tutor group #{tg.name} has #{tg.size} pupils." if loader.options.verbose
      tg.finalize
    end
    without_tutor, with_tutor = tgs.partition {|tg| tg.staff == nil}
    without_tutor.each do |tg|
      puts "Dropping tutor group #{tg.name} because it has no tutor." if loader.options.verbose
    end
    #
    #  And link them to houses?
    #
    with_tutor.each do |tug|
      tug.link_to_house
    end
    with_tutor
  end

end


