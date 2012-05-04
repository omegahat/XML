libary(XML)

ab = readHTMLTable("http://www.greenbuilder.com/general/countries.html")

ab1 = readHTMLTable("http://www.worldatlas.com/aatlas/ctycodes.htm")

ab2 = readHTMLTable('http://www.buzzle.com/articles/list-of-country-abbreviations.html')[[4]]

# Now.
ab3 = readHTMLTable('http://www.iso.org/iso/english_country_names_and_code_elements')



tt = readHTMLTable("http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3314655/table/pone-0032723-t004", which = 2, skip.rows = 2)

