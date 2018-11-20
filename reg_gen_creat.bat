
set project=FM399

perl reg_gen.pl -c %project% -d .\v
:: perl reg_gen.pl -c %project% -l vfile.flist
:: perl reg_gen.pl -c %project% -f .\v\stimer_reg_desc.v

@call .\xlsx2doc\bin\regspec2doc.exe .\result\gen_uvm_%project%.xlsx

move .gen.docx .\result\gen_%project%_regs.docx 
