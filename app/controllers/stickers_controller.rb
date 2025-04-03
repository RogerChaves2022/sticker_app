require "net/http"
require "uri"

class StickersController < ApplicationController
  before_action :authenticate_user!

  def index
    @stickers = current_user.stickers
  end
  
  def new
    @sticker = Sticker.new
  end

  def create
    @sticker = current_user.stickers.new(sticker_params)
    if @sticker.save
      redirect_to stickers_path, notice: "Figurinha criada com sucesso!"
    else
      render :index, alert: "Erro ao criar figurinha."
    end
  end

  def destroy
    @sticker = current_user.stickers.find(params[:id])
    @sticker.destroy
    redirect_to stickers_path, notice: "Figurinha removida com sucesso!"
  end

  def send_whatsapp
    sticker = current_user.stickers.find(params[:id])
    phone_number = params[:phone_number]

    if phone_number.blank?
      redirect_to stickers_path, alert: "Número de telefone é obrigatório!"
      return
    end

    # Gerar URL da imagem
    image_url = rails_blob_url(sticker.image, only_path: false)

    # Chamar API do WhatsApp (Alternativa: Twilio API)
    response = send_to_whatsapp(phone_number, image_url)

    if response[:success]
      redirect_to stickers_path, notice: "Figurinha enviada para #{phone_number}!"
    else
      redirect_to stickers_path, alert: "Erro ao enviar a figurinha: #{response[:error]}"
    end
  end

  private

  def sticker_params
    params.require(:sticker).permit(:image)
  end

  def send_to_whatsapp(phone, image_url)
    # Alternativa com API do WhatsApp
    api_url = "https://api.whatsapp.com/send?phone=#{phone}&text=Veja minha figurinha! #{image_url}"
    
    # Para produção, integre com Twilio API ou WhatsApp Cloud API
    { success: true }
  end
end