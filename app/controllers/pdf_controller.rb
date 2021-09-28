class PdfController < ApplicationController
    before_action :clean_db
    def create 
        pdf = PdfDocument.new pdf_params 
        if pdf.save
            begin 
                pdf.process_file split: 1
                if pdf.save 
                    render json: PdfDocumentSerializer.new(pdf).serializable_hash, status: :ok
                else
                    pdf.destroy
                    render status: :bad_request 
                end
            rescue => exception
                pdf.destroy 
                render  status: :bad_request 
            end 
        else 
            render json: {error: pdf.errors.full_messages}, status: :bad_request 
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
