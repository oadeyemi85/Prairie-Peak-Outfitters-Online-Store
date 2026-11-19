class PagesController < ApplicationController
  def show
    @page = Page.find_by!(slug: params[:slug])
    set_breadcrumbs([@page.title, nil])
  end
end
