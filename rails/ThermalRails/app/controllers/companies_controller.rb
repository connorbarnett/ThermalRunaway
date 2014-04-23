class CompaniesController < ApplicationController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }


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

  # GET /companies/lookup
  #GET /companies/lookup.json
  # Looks up a company pertaining to a specific name
  def lookup
    @company = Company.find_by(name: params[:name])
    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: @company }
    end
  end
  
  # PATCH/PUT /increment
  # Records a single vote for a single company
  # Need to pass in params of name, vote_type and vote_location
  def vote
    @company = Company.find_by(name: params[:name])

    vote = Vote.new
    vote.company = params[:name]
    vote.vote_type = params[:vote_type] 
    vote.vote_location = params[:vote_location]

    if !@company.nil?
      @company.votes << vote
    end

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render json: @company }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  #GET /vote/lookup
  #GET /vote/lookup.json
  def voteLookup
    @company = Company.find_by(name: params[:name])
    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: @company.votes }
    end
  end

  #GET /vote/count
  #GET /vote/count.json
  def voteCount
    @company = Company.find_by(name: params[:name])
    respond_to do |format|
      format.html { redirect_to @company}
      format.json { render json: @company.votes.count }
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
      params.require(:company).permit(:name, :img_url, :vote_type, :vote_location)
    end
end
