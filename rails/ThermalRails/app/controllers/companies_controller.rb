class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'new' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /lookup
  #GET /lookup.json
  # Looks up a company pertaining to a specific name
  def lookup
    @company = Company.find_by(name: params[:name])
    puts params
    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: @company }
    end
  end
  
  # PATCH/PUT /increment
  # Need to pass in params of id and vote_type
  #increments the vote type's value by 1
  #Potential update is to find over the name instead of id
  def increment
    @user = Company.find_by(name params[:name])
    vote_type = params[:vote_type]
   
    @vote = Vote.new
    @vote.company = params[:company]
    @vote.vote_type = vote_type
    @vote.vote_location = vote_location
    
    if vote_type == "up_vote"
      @user.up_votes = @user.up_votes + 1
    end
    if vote_type == "down_vote"
      @user.down_votes = @user.down_votes + 1
    end
    if vote_type == "unknown_vote"
      @user.num_unknown = @user.num_unknown + 1
    end
  
    respond_to do |format|
      if @user.save and @vote.save
        format.html { redirect_to @user, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :up_votes, :down_votes)
    end
end
