class PdfController < ApplicationController
    def create 
        pdf = PdfParser::Document.new file: params[:pdf_file]
        if params[:table]
            header_index = params["row-index"] || params["index"] || 1
            table = pdf.tableize header_index.to_i, **table_params
            render json: pdf.tables, status: :ok
        else 
             render json: pdf.lines, status: :ok 
        end
    end

    private
\

    def pdf_params
        params.permit(:pdf_file)
    end

    def table_params
        params.permit(:name, :only, :exclude, :max, :wiggle, :alignment)
    end
end
