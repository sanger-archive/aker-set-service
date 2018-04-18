module MaterialsEdition
  extend ActiveSupport::Concern

  included do
    attr_accessor :owner_id
    skip_authorization_check only: [:create, :index, :show]
    skip_credentials only: [:show, :index]

    before_action :validate_uuids, only: [:update_relationship, :create_relationship]
    before_action :create_uuids, only: [:update_relationship, :create_relationship]

    before_action :authorise_write, only: [:create_relationship, :update_relationship, :destroy_relationship, :update, :destroy]
    before_action :set_owner, only: :create    
    before_action :check_lock, only: [:update, :destroy, :update_relationship, :create_relationship, :destroy_relationship]
  end

  # This is the only way I found to prevent deleting materials from a set via 'patch'
  def check_lock
    if Aker::Set.find(resource_id).locked?
      return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Set is locked' }]}, status: :unprocessable_entity
    end
  end

  def set_owner
    self.owner_id = params.fetch(:data).dig("attributes", "owner_id")
    params["data"]["attributes"].delete("owner_id") if self.owner_id
  end


  # Fail request if the materials do not exist in materials service
  def validate_uuids
    unless Material.valid?(param_uuids)
      return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Invalid Material UUIDs' }]}, status: :unprocessable_entity
    end
  end

  def create_uuids
    existing_materials = Aker::Material.where(id: param_uuids).pluck(:id)
    materials_to_create = param_uuids - existing_materials
    time = Time.now
    Aker::Material.bulk_insert(:id, :created_at, :updated_at, values: materials_to_create.map {|id| {id: id, created_at: time, updated_at: time} })
  end

  def context
    super.merge({owner_id: owner_id})
  end

end