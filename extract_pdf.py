import PyPDF2
import sys

def extract_pdf_text(pdf_path):
    try:
        with open(pdf_path, 'rb') as pdf_file:
            reader = PyPDF2.PdfReader(pdf_file)
            text = ""
            for i, page in enumerate(reader.pages):
                text += f"\n\n--- Page {i+1} ---\n\n"
                text += page.extract_text()
            return text
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    pdf_path = "melon.pdf"
    text = extract_pdf_text(pdf_path)
    with open("cahier_des_charges.txt", "w", encoding="utf-8") as f:
        f.write(text)
    print("Extraction completed successfully!")
