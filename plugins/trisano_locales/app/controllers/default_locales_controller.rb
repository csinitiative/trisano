# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class DefaultLocalesController < AdminController
  reloadable!

  before_filter :load_current

  def show
    # handled in filter
  end

  def edit
    # handled in filter
  end

  def update
    @default_locale.short_name = params[:short_name]
    @default_locale.user_id = User.current_user.id
    respond_to do |format|
      if @default_locale.save
        I18n.default_locale_without_db = @default_locale.to_sym
        flash[:notice] = I18n.t('successful_update', :scope => trisano_locale_scope)
        format.html { redirect_to default_locale_path }
      else
        format.html { render :action => :edit, :status => :bad_request }
      end
    end
  end

  protected

  def access_granted?
    super && User.current_user.is_entitled_to?(:manage_locales)
  end

  def load_current
    @default_locale = DefaultLocale.current || DefaultLocale.new(:short_name => I18n.default_locale)
  end
end
