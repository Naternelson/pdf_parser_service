class PdfController < ApplicationController

    def create 
        pdf = PdfDocument.new pdf_params 
        if pdf.save
            begin 
                pdf.process_file split: 1
                binding.pry 
            rescue

            end 
        end
    end

    private
    def pdf_params
        params.permit(:pdf_file)
    end
end
