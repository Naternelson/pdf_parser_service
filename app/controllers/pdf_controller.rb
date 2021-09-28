class PdfController < ApplicationController
    before_action :clean_db
    def create 
        pdf = PdfDocument.new pdf_params 
        if pdf.save
            begin 
                pdf.process_file split: 1
            rescue

            end 
        end
    end

    private
    def clean_db
        PdfDocument.clean
    end

    def pdf_params
        params.permit(:pdf_file)
    end
end
