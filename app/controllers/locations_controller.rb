# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2020 John Winters
# See COPYING and LICENCE in the root directory of the application
# for more information.

class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]


  # GET /locations
  # GET /locations.json
  def index
    if params[:owned]
      @locations = Location.owned.page(params[:page]).order('name')
    else
      @locations = Location.page(params[:page]).order('name')
    end
  end

  # GET /locations/tree
  #
  # A bit like index, but show only those in a subsidiary relationship
  # and show them in tree form.
  #
  def tree
    @location_tree_nodes =
      LocationTreeNode.generate(Location.current.includes(:element).all)
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    session[:new_location_from] = request.env['HTTP_REFERER']
    @cancel_to = request.env['HTTP_REFERER']
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
    session[:editing_location_from] = request.env['HTTP_REFERER']
    @cancel_to = request.env['HTTP_REFERER']
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to session[:new_location_from], notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to session[:editing_location_from], notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.json { head :no_content }
    end
  end

  #
  #  Provide an autocomplete method for looking up locations directly.
  #  We can almost do:
  #
  # autocomplete :location, :name, scopes: [:current, :active], full: true
  #
  #  but we want to be able to find locations by their element names,
  #  which are generated by the locations but stored in the element.
  #
  #
  def autocomplete_location_name
    term = params[:term].split(" ").join("%")
    elements =
      Element.location.current.
              where('elements.name LIKE ?', "%#{term}%").
              order("LENGTH(elements.name)").
              order(:name).
              all
    render json: elements.map { |element|
      {
        #
        #  Note that the selector above restricted us to choosing
        #  just elements related to locations, so now we can pick
        #  the entity id out of the element record, confident that
        #  it's the id of a location.
        #
        id:    element.entity_id,
        label: element.name,
        value: element.name
      }
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).
             permit(:name,
                    :active,
                    :current,
                    :num_invigilators,
                    :weighting,
                    :subsidiary_to_id,
                    :subsidiary_to_name)
    end
end
