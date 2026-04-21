class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    # HoneyPot
    if params[:website].present?
      redirect_to contact_path, notice: "お問い合わせを受け付けました。"
      return
    end

    @contact = Contact.new(contact_params)

    if @contact.save
      # 最初は確実性重視で deliver_now 推奨（本番確認後に deliver_later にしてもOK）
      ContactMailer.admin_notification(@contact).deliver_now

      redirect_to contact_path, notice: "お問い合わせを受け付けました。返信までしばらくお待ちください。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
