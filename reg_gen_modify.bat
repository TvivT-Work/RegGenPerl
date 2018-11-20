
set project=FM333

perl reg_gen.pl -m %project% -d .\v
:: perl reg_gen.pl -m %project% -l vfile.flist
:: perl reg_gen.pl -m %project% -f .\v\stimer_reg_desc.v

@call .\xlsx2doc\bin\regspec2doc.exe .\result\modify_uvm_%project%.xlsx

move .gen.docx .\result\modify_%project%_regs.docx 
