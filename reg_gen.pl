#!/usr/bin/perl -w
# use strict;
 
use utf8;
use POSIX;
use List::Util qw/max min/;
use Excel::Writer::XLSX;
use Encode; 
# use open ":encoding(gbk)", ":std";
use open ":encoding(utf8)", ":std";
use open ":encoding(utf8)"; #如果文件全是 gbk，那么承上编码设置，此行可省略

my $filecount  = 0; 
my $vfilecount = 0; 
my @dir_files;
my @vfiles;
 
# local $\ ="\n"; # every line print auto add \n
 
#=========================== System Information ===============================
$os = $^O;
$user_name = ($os =~ /MSWin32/) ? $ENV{'USERNAME'} :
             ($os =~ /linux/  ) ? $ENV{'USER'}     : "Unknow" ;

#=========================== Arguments Checker ===============================
$argv_total_num = $#ARGV + 1;

if( $argv_total_num == 0 ) {
    disp_usage();
    die "ERROR: NO Arguments !!! \n\n";
} elsif( $argv_total_num < 4 ) {
    disp_usage();
    die "ERROR: Arguments Error !!! \n\n";
}

if($ARGV[0] =~ /\-c/) {
  $gen_type = 1; #Creat
}
elsif($ARGV[0] =~ /\-m/) {
  $gen_type = 0; #Modify
}

$project_name   = $ARGV[1];

#=========================== Get File List ===============================
@vfiles = ();
if($ARGV[2] =~ /\-d/) {
    @vfiles = get_dir_vfiles($ARGV[3]);
}
elsif($ARGV[2] =~/\-l/) {

    open (filelist_handle,"<:encoding(utf8)",$ARGV[3]);
    @file_list=<filelist_handle>;
    foreach my $vfile(@file_list){
      chomp($vfile);

      # Replace Space
      $vfile =~ s/\s//g;

      # Replace Comment 
      $vfile =~ s/\/\/[\s\S]*//g;

      # Skip empty lines
      if ($vfile =~ /^\s*$/) {
        next;
      }

      # $vfile =~ s/\\/\\\\/g;
      push (@vfiles, $vfile);
    }

}
elsif($ARGV[2] =~/\-f/) {
    for my $argv_num (3..$#ARGV){
      push (@vfiles, $ARGV[$argv_num]);
    }
}
else {
    disp_usage();
    die "ERROR: Error Arguments !!! \n\n";
}

print ("\n Read vfiles: @vfiles \n");

#================================  DIR  ===================================
if($user_name eq "jianghe") {
  $result_dir = "D:\\Desktop\\Perl_Result\\";
}
else {
  $result_dir = ".\\result\\";
}

if(-e $result_dir) {
  print("\n DIR \"$result_dir\" Exist \n\n");
  print(" Generate Files SAVE to DIR: $result_dir \n\n");
}
else {
  mkdir $result_dir ;
  print("\n DIR \"$result_dir\" Make \n\n");
  print(" Generate Files SAVE to DIR: $result_dir \n\n");
}
#=========================== Files Generate ===============================
 
foreach $vfile (@vfiles) {
  module_rd_parser($vfile);
  module_verilog_export();
  module_vdef_export();
  module_hdef_export();
  module_ctest_export();
  read_excel_export();
}

uvm_excel_export();

# chomp ($key_input=<STDIN>);

#########################################################################################################
#=========================================================================
sub disp_usage {
    print "\n";
    print "==================================================\n";
    print "  Usage: reg_gen -c/-m project_name read_excel_gen(0/1) -d input_dir      \n";
    print "         reg_gen -c/-m project_name read_excel_gen(0/1) -f input_file1.v   input_file2.v ... \n";
    print "         reg_gen -c/-m project_name read_excel_gen(0/1) -l input_filelist \n";
    print "         -c : Creat                               \n";
    print "         -m : Modify                              \n";
    print "==================================================\n";
    print "\n";
}


sub get_dir_vfiles {

  my $path = $_[0]; #或者使用 my($path) = @_; @_类似javascript中的arguments
  my $subpath;
  my $handle; 

  if ($path =~ /\\$/) {
  }
  else {
    $path .= "\\" ;
  }

  if (-d $path) {#当前路径是否为一个目录
    if (opendir($handle, $path)) {
      while ($subpath = readdir($handle)) {
        if (!($subpath =~ m/^\.$/) and !($subpath =~ m/^(\.\.)$/)) {
          my $dir_file = $path."/$subpath"; 
 
          if (-d $dir_file) {
            get_dir_vfiles($dir_file);
          } else {
            ++$filecount;
            if($dir_file =~ /\.v$|\.sv$/) {
              ++$vfilecount;
              push (@dir_files, $dir_file);
              # print $p."\n";
            }
          }
        }                
      }
      closedir($handle);            
    }
  } 
 
  return @dir_files;

  # $dir_path = $_[0];

  # if ($dir_path =~ /\\$/) {
  # }
  # else {
  #   $dir_path .= "\\" ;
  # }

  # opendir (DIR, $dir_path) || die"$!";
  # # chdir($dir_path);
  
  # @dir_fnames=grep{/\.v$|\.sv$/}readdir DIR;
  
  # foreach $filename(@dir_fnames){
  #   $dir_file = $dir_path.$filename; 
  #   push (@dir_files, $dir_file);
  # }
  
  # close DIR;

  # return @dir_files;

}

sub conv_num_str_base {
  $num_str = $_[0];
  $num_len = $_[1];
  $num_str =~ s/\_//g   ;

  if($num_str =~/'h/ ) {
    $num_start = index($num_str,    "'h") + 2;
    $num_hex   = uc(substr($num_str, $num_start));
    $num_hex   = "0"x(POSIX::ceil($num_len/4)-length($num_hex)).$num_hex;
    $num_dec   = hex($num_hex);
    $num_bin   = sprintf("%0b", $num_dec);
    $num_bin   = "0"x($num_len-length($num_bin)).$num_bin;
  }
  elsif($num_str =~/'d/ ) {
    $num_start = index($num_str,    "'d") + 2;
    $num_dec   = substr($num_str, $num_start);
    $num_hex   = uc(sprintf("%0x", $num_dec));
    $num_hex   = "0"x(POSIX::ceil($num_len/4)-length($num_hex)).$num_hex;
    $num_bin   = sprintf("%0b", $num_dec);
    $num_bin   = "0"x($num_len-length($num_bin)).$num_bin;
  }
  elsif($num_str =~/'b/ ) {
    $num_start = index($num_str,    "'b") + 2;
    $num_bin   = substr($num_str, $num_start);
    $num_bin   = "0"x($num_len-length($num_bin)).$num_bin;
    $num_dec   = oct("0b".$num_bin);
    $num_hex   = uc(sprintf("%0x", $num_dec));
    $num_hex   = "0"x(POSIX::ceil($num_len/4)-length($num_hex)).$num_hex;
  }

  return($num_bin, $num_dec, $num_hex);

}

#=========================================================================
sub  module_rd_parser {

  $reg_descript_file = $_[0] ;

  @reg_list    = ();
  $reg_one_gen = 0 ;

  open (file_handle,"<:encoding(utf8)", $reg_descript_file);

  @line_list=<file_handle>;

  foreach $current_line(@line_list){

    # Replace Comment 
    $current_line =~ s/\/\/[\s\S]*//g;

    # Skip empty lines
    if ($current_line =~ /^\s*$/) {
      next;
    }

    # Module_head
    if( $current_line =~ /module_name/ ) {
      @line_content     = split(/:/,$current_line) ;
      $module_name      = $line_content[1]         ;
      $module_name      =~ s/\s//g                 ;
      $module_name_len  = length($module_name)     ;
    }

    #--------------------------------------------------------------------------------
    # Define
    if( $current_line =~ /defbegin/ ) {

      $current_line =~ s/\s//g ;

      @line_content = split(/[:,]/,$current_line);

      $reg_base_name  =  $line_content[1] ;
      $reg_base_addr  =  $line_content[2] ;
      $reg_base_space =  $line_content[3] ;


      $reg_base_addr  =~ s/\_//g          ;

      @reg_base_addr_bdh = conv_num_str_base($reg_base_addr, 32) ;
      $reg_base_addr_hex = $reg_base_addr_bdh[2]                 ;

      $def_flag  = 1 ;

      next;

    }

    if( $current_line =~ /defend/ ) {

      $current_line =~ s/\s//g ;

      $def_flag = 0;

    }

    if($def_flag) {

      $current_line =~ s/\s//g ;

      @line_content = split(/[:,]/,$current_line);

      $reg_one_reg_name =  $line_content[0] ;
      $reg_one_ofs_name =  $line_content[1] ;
      $reg_one_ofs_addr =  $line_content[2] ;

      @reg_one_ofs_addr_bdh = conv_num_str_base($reg_one_ofs_addr, 32) ;
      $reg_one_ofs_addr_hex = $reg_one_ofs_addr_bdh[2]                 ;

      $reg_one_macro_name_hash{$reg_one_reg_name} = $reg_one_ofs_name     ;
      $reg_one_macro_addr_hash{$reg_one_reg_name} = $reg_one_ofs_addr_hex ;

    }

    if($gen_type) {
      $reg_one_gen = 1;
    }
    else {
      if( $current_line =~ /`modify/ ) {
        $reg_one_gen = 1
      }
      if( $current_line =~ /`endmodify/ ) {
        $reg_one_gen = 0
      }
    }

    if($reg_one_gen) {
      # Register 
      # @reg_list(@reg_one1, @reg_one2);
      # @reg_one(@reg_name, @reg_addr, @reg_bit1, @reg_bit2)
      # @reg_name(reg_name)
      # @reg_addr(reg_addr)
      # @reg_bit(0  bit_name, 
      #          1  bit_end_addr, 
      #          2  bit_start_addr, 
      #          3  bit_def, 
      #          4  bit_len, 
      #          5  bit_len_minus1, 
      #          6  bit_def_bin, 
      #          7  bit_def_hex, 
      #          8  bit_wr_access,
      #          9  bit_descript  ) 
      if( $current_line =~ /regbegin/ ) {

        $current_line =~ s/\s//g ;

        @line_content = split(/[:,]/,$current_line);

        $reg_name  = $line_content[1]                    ;
        $reg_addr  = $reg_one_macro_name_hash{$reg_name} ;
        @reg_one   = ([$reg_name], [$reg_addr])          ;

        $reg_bit_flag = 1;

        next;

      }

      if( $current_line =~ /regend/ ) {

        $current_line =~ s/\s//g ;

        push(@reg_list, [@reg_one]);

        $reg_bit_flag = 0;

      }

      if($reg_bit_flag) {

        @reg_bit         = split(/,/, $current_line) ;

        $reg_bit_name      = $reg_bit[0];
        $reg_bit_start     = $reg_bit[1];
        $reg_bit_def       = $reg_bit[2];
        $reg_bit_wr_acc    = $reg_bit[3];
        $reg_bit_descript  = $reg_bit[4];
        if($#reg_bit>4) {
          for $num (5..$#reg_bit) {
            $reg_bit_descript .= ",";
            $reg_bit_descript .= $reg_bit[$num];
          }
        }
        
        $reg_bit_name      =~ s/\s//g ;
        $reg_bit_start     =~ s/\s//g ;
        $reg_bit_def       =~ s/\s//g ;
        $reg_bit_wr_acc    =~ s/\s//g ;
        if($#reg_bit >= 4) {
        $reg_bit_descript  =~ s/^\s*//g ;
        $reg_bit_descript  =~ s/\s*$//g ;
        }

        @reg_bit_def_temp = split(/'/, $reg_bit_def)          ;
        $reg_bit_len      = $reg_bit_def_temp[0]              ;

        $reg_bit_len_m1   = $reg_bit_len - 1                  ;

        $reg_bit_end      = $reg_bit_start + $reg_bit_len_m1  ; 
         
        @reg_bit_def_bdh = conv_num_str_base($reg_bit_def, $reg_bit_len) ;
        $reg_bit_def_bin = $reg_bit_def_bdh[0]                      ;
        $reg_bit_def_hex = $reg_bit_def_bdh[2]                      ;

        $reg_bit[0] = $reg_bit_name       ;
        $reg_bit[1] = $reg_bit_end        ;
        $reg_bit[2] = $reg_bit_start      ;
        $reg_bit[3] = $reg_bit_def        ;
        $reg_bit[4] = $reg_bit_len        ;
        $reg_bit[5] = $reg_bit_len_m1     ;
        $reg_bit[6] = $reg_bit_def_bin    ;
        $reg_bit[7] = $reg_bit_def_hex    ;
        $reg_bit[8] = lc($reg_bit_wr_acc) ;
        $reg_bit[9] = $reg_bit_descript   ;

        push(@reg_one, [@reg_bit]);

      }
    }

  }
  close file_handle;

  # Align 
  
  # Register 
  # @reg_list(@reg_one1, @reg_one2);
  # @reg_one(@reg_name, @reg_addr, @reg_bit1, @reg_bit2)
  # @reg_name(reg_name, reg_name_align)
  # @reg_addr(reg_addr, reg_addr_align)
  # @reg_bit(0 bit_name, 
  #          1  bit_end_addr, 
  #          2  bit_start_addr, 
  #          3  bit_def, 
  #          4  bit_len, 
  #          5  bit_len_minus1, 
  #          6  bit_def_bin, 
  #          7  bit_def_hex, 
  #          8  bit_wr_access, 
  #          9  bit_name_align, 
  #          10 bit_len_align, 
  #          11 bit_len_minus1_align,
  #          12 bit_descript         )
    
  
  #get str max length
  for $reg_num (0..$#reg_list) {
  
    $reg_name = $reg_list[$reg_num][0][0];
    $reg_addr = $reg_list[$reg_num][1][0];
    push(@reg_name_str_len, length($reg_name));
    push(@reg_addr_str_len, length($reg_addr));
  
    for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
      $reg_bit_name    = $reg_list[$reg_num][$reg_bit_num][0];
      push(@reg_bit_name_str_len, length($reg_bit_name));
    }
  
  }
  
  push(@reg_bit_name_str_len, $module_name_len+8);
  
  $reg_name_len_max     = max(@reg_name_str_len    );
  $reg_addr_len_max     = max(@reg_addr_str_len    );
  $reg_bit_name_len_max = max(@reg_bit_name_str_len);
  
  #format str same len
  for $reg_num (0..$#reg_list) {
  
    $reg_name       = $reg_list[$reg_num][0][0];
    $reg_addr       = $reg_list[$reg_num][1][0];
  
    $reg_name_align = $reg_name." " x ($reg_name_len_max + 2 - length($reg_name)) ;
    $reg_addr_align = $reg_addr." " x ($reg_addr_len_max + 2 - length($reg_addr)) ;
  
    $reg_list[$reg_num][0][1] = $reg_name_align;
    $reg_list[$reg_num][1][1] = $reg_addr_align;
  
    for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {

      $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][0];
      $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][1];
      $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][2];
      $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][3];
      $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][4];
      $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][5];
      $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][6];
      $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][7];
      $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][8];
      $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][9];

      $reg_bit_name       = $reg_list[$reg_num][$reg_bit_num][0];
      $reg_bit_name_align = $reg_bit_name." " x ($reg_bit_name_len_max + 2 - length($reg_bit_name));
       
      $reg_list[$reg_num][$reg_bit_num][9] = $reg_bit_name_align ;
 

      if($reg_bit_len<10) {
        $reg_bit_len_align = " ".$reg_bit_len;
      }
      else {
        $reg_bit_len_align = $reg_bit_len;
      }

      $reg_list[$reg_num][$reg_bit_num][10] = $reg_bit_len_align ;
     

      if($reg_bit_len_m1<10) {
        $reg_bit_len_minus1_align = " ".$reg_bit_len_m1;
      }
      else {
        $reg_bit_len_minus1_align = $reg_bit_len_m1;
      }

      $reg_list[$reg_num][$reg_bit_num][11] = $reg_bit_len_minus1_align ;
      $reg_list[$reg_num][$reg_bit_num][12] = $reg_bit_descript         ;
    }
  
  }

}


#=========================================================================
sub  module_verilog_export {

  @gen_line         = (); 
  @module_head_line = ();
  @reg_declare_line = ();
  @reg_assign_line  = ();
  @reg_read_line    = ();
  @reg_write_line   = ();
  @new_line         = ();

  if($gen_type) {
    $verilog_filename = "gen_".$module_name."_csr.v";
  }
  else {
    $verilog_filename = "modify_".$module_name."_csr.v";
  }
  
  $verilog_exist = -e $result_dir.$verilog_filename;
  
  if ( $verilog_exist ) {
    print "$verilog_filename Exist, OverWrite it ? <y/n> (default OverWrite): ";
    chomp ($key_input=<STDIN>);
  
    if($key_input eq "n") {
      print"\n -------- $verilog_filename No Change !!! -------- \n\n";
      $verilog_gen   = 0;
     }
     else{
      print"\n -------- $verilog_filename OverWrite !!! -------- \n\n";
      $verilog_gen = 1;
     }
  } 
  else {
    $verilog_gen = 1;
  }
  
  if($verilog_gen) {
    #========================== Module Head Gen =============================
    $today_date =strftime("%Y%m%d",localtime());
  
    @new_line = (
                  "//=================================================================================\n",
                  "// Filename: ${module_name}_csr\.v                                                 \n",
                  "// Author  : $user_name                                                            \n",
                  "// Abstract:                                                                       \n",
                  "//---------------------------------------------------------------------------------\n",
                  "// Description:                                                                    \n",
                  "//                                                                                 \n",
                  "//---------------------------------------------------------------------------------\n",
                  "// Modification History:                                                           \n",
                  "//---------------------------------------------------------------------------------\n",
                  "//    Rev           date          Author         description                       \n",
                  "//    0.00         $today_date       $user_name           Creat it                 \n",
                  "//=================================================================================\n",
                  "\`timescale 1ns\/10ps                                                              \n",
                  "\n",
                  "\n",
                  "module ${module_name}_csr(\n",
                  "    input  wire   [31:0]   ${module_name}_paddr              ,\n",
                  "    input  wire   [31:0]   ${module_name}_pwdata             ,\n",
                  "    input  wire            ${module_name}_pwrite             ,\n",
                  "    input  wire   [ 3:0]   ${module_name}_pstrb              ,\n",
                  "    input  wire            ${module_name}_psel               ,\n",
                  "    input  wire            ${module_name}_penable            ,\n",
                  "    input  wire   [ 2:0]   ${module_name}_pprot              ,\n",
                  "    input  wire   [ 2:0]   ${module_name}_pmaster            ,\n\n",
                                                                           
                  "    output wire   [31:0]   ${module_name}_prdata             ,\n",
                  "    output wire            ${module_name}_pready             ,\n",
                  "    output wire            ${module_name}_pslverr            ,\n\n",
                );
    push(@module_head_line, @new_line);
  
    #input wire declare
    for $reg_num (0..$#reg_list) {
  
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      # $new_line = "    //REG $reg_name\n";
      # push(@module_head_line, $new_line);
  
     # $new_line = "    //$reg_name_align Input \n";
     # push(@module_head_line, $new_line);

      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
  
        $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
        $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
        $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
        $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
        $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
        $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
        $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
        $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
        $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
        $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
        $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
        $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
        $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
        $reg_bit_name_len     = length($reg_bit_name) ;
  
        if($reg_bit_wr_access =~ /ro/) {
            if($reg_bit_len == 1) {
              $new_line = "    input  wire            $reg_bit_name_align         ,\n";
            }
            else {
              $new_line = "    input  wire   [$reg_bit_len_m1_align:0]   $reg_bit_name_align         ,\n";
            }
            push(@module_head_line, $new_line);
          }
  
        }
  
      }
  
    #output reg declare
    $new_line = "\n\n";
    push(@module_head_line, $new_line);
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      # $new_line = "    //$reg_name_align Output \n";
      # push(@module_head_line, $new_line);

      # $new_line = "    //REG $reg_name\n";
      # $new_line = "\n";
      # push(@module_head_line, $new_line);
      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
        $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
        $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
        $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
        $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
        $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
        $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
        $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
        $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
        $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
        $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
        $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
        $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
        $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
        $reg_bit_name_len     = length($reg_bit_name) ;
  
        if($reg_bit_wr_access =~ /w/) {
          if($reg_bit_len == 1) {
            $new_line = "    output reg             $reg_bit_name_align         ,\n";
          }
          else {
            $new_line = "    output reg    [$reg_bit_len_m1_align:0]   $reg_bit_name_align         ,\n";
          }
          push(@module_head_line, $new_line);
        }
      }
    }
  
    @new_line = (
                  "                                                                                  \n",
                  "    input  wire            ${module_name}_pclk               ,                         \n",
                  "    input  wire            ${module_name}_rst_n                                        \n",
                  "                                                                                  \n",
                  ");                                                                                \n",
                  "                                                                                  \n",
                  "                                                                                  \n",
                );
    push(@module_head_line, @new_line);
  
    #============================ Declare Gen ================================
    $new_line = "//==========================================  DECLARE  ==========================================\n",
    push(@reg_declare_line, $new_line);
  
    $new_line  = "assign  ${module_name}_pready  = 1'b1";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n"    ;
    push(@reg_declare_line, $new_line);
  
    $new_line = "assign  ${module_name}_pslverr = 1'b0";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n"    ;
    push(@reg_declare_line, $new_line);
  
    push(@reg_declare_line, "\n" );
  
    $new_line = "//--------------------------------------------------------  \n";
    push(@reg_declare_line, $new_line);
  
    $new_line  = "wire    ${module_name}_mmu_cs";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n"    ;
    push(@reg_declare_line, $new_line);
    $new_line  = "assign  ${module_name}_mmu_cs = ${module_name}_psel & ${module_name}_penable";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n\n"    ;
    push(@reg_declare_line, $new_line);
  
    $new_line  = "wire    super_access";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n"    ;
    push(@reg_declare_line, $new_line);
    $new_line  = "assign  super_access = ${module_name}_pprot[0]";
    $new_line .= " " x (60 - length($new_line)) ;
    $new_line .= ";\n"    ;
    push(@reg_declare_line, $new_line);
  
    $new_line = "//--------------------------------------------------------  \n\n";
    push(@reg_declare_line, $new_line);
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      $new_line = "wire              cs_$reg_name_align       ;\n";
      push(@reg_declare_line, $new_line);
    }
    push(@reg_declare_line, "\n");
  
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      @reg_all_bit_wacc     = () ;
      $reg_one_write_access = 0  ;
      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
        $reg_bit_wr_access = $reg_list[$reg_num][$reg_bit_num][8];
        $reg_bit_wr_logic  = ($reg_bit_wr_access =~ /ro/) ? 0 : 1;
        push(@reg_all_bit_wacc, $reg_bit_wr_logic);
      }
      $reg_one_write_access = max(@reg_all_bit_wacc);
  
      if($reg_one_write_access) {
        $new_line = "wire              wr_$reg_name_align       ;\n";
        push(@reg_declare_line, $new_line);
      }
  
    }
    push(@reg_declare_line, "\n");
  
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      $new_line = "wire              rd_$reg_name_align       ;\n";
      push(@reg_declare_line, $new_line);
    }
    push(@reg_declare_line, "\n");
  
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      $new_line = "wire     [31:0]   data_$reg_name_align     ;\n";
      push(@reg_declare_line, $new_line);
    }
    push(@reg_declare_line, "\n" x 2);
  
  
    #============================ Assign Gen =================================
    $new_line = "//==========================================  ASSIGN  ===========================================\n",
    push(@reg_assign_line, $new_line);
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
  
      $new_line = "assign  cs_$reg_name_align     = ( ${module_name}_mmu_cs & {${module_name}_paddr[11:2],2'b0}==$reg_addr_align );\n";
      push(@reg_assign_line, $new_line);
    }
    push(@reg_assign_line, "\n");
  
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];

      @reg_all_bit_wacc     = () ;
      $reg_one_write_access = 0  ;
      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
        $reg_bit_wr_access = $reg_list[$reg_num][$reg_bit_num][8];
        $reg_bit_wr_logic  = ($reg_bit_wr_access =~ /ro/) ? 0 : 1;
        push(@reg_all_bit_wacc, $reg_bit_wr_logic);
      }
      $reg_one_write_access = max(@reg_all_bit_wacc);
 
      if($reg_one_write_access) {
        $new_line = "assign  wr_$reg_name_align     = ( cs_$reg_name_align   &  ${module_name}_pwrite );\n";
        push(@reg_assign_line, $new_line);
      }

    }
    push(@reg_assign_line, "\n");
  
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      $new_line = "assign  rd_$reg_name_align     = ( cs_$reg_name_align   & ~${module_name}_pwrite );\n";
      push(@reg_assign_line, $new_line);
    }
    push(@reg_assign_line, "\n" x 2);
  
  
    #============================ Read Gen ===================================
    $new_line = "//============================================  REG  READ  ============================================\n",
    push(@reg_read_line, $new_line);
  
    for $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
  
      $reg_bit_ptr = 31;
  
      $new_line = "assign  data_$reg_name_align   = { ";
  
      #Add Highest Zero
      $high_zero_num = 31-$reg_list[$reg_num][2][1];
      if($high_zero_num == 0) {
        $new_line_add = "";
      }
      elsif($high_zero_num < 4) {
        $new_line_add  = " ${high_zero_num}'b" ;
        $new_line_add .= "0" x $high_zero_num  ;
        $new_line_add .= ", "                  ;
      }
      elsif($high_zero_num < 10) {
        $new_line_add  = " ${high_zero_num}'h0, " ;
      }
      else {
        $new_line_add  = "${high_zero_num}'h0, " ;
      }
  
      $reg_bit_ptr = 31 - $high_zero_num;
  
      $new_line .= $new_line_add;
  
      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
  
        $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
        $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
        $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
        $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
        $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
        $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
        $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
        $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
        $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
        $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
        $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
        $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
        $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
        # Add Zero Between Reg_Bit
        if($reg_bit_ptr != $reg_bit_end) {
          $add_zero_num  = $reg_bit_ptr - $reg_bit_end ;
  
          if($add_zero_num < 4) {
            $new_line .= " ${add_zero_num}'b" ;
            $new_line .= "0" x $add_zero_num  ;
            $new_line .= ", "                 ;
          }
          else {
            $new_line     .= "${add_zero_num}'h0, "      ;
          }
        }
  
        if($reg_bit_wr_access =~ /(ro|rw|w1c)/i) {
          $new_line .= "$reg_bit_name";
        }
        if($reg_bit_wr_access =~ /wo/i) {
          $new_line .= "${reg_bit_len}'h";
          $new_line .= "$reg_bit_def_hex";
        }
  
        $reg_bit_ptr = $reg_bit_start - 1;
  
        #Last Reg_Bit
        if( $reg_bit_num == $#{$reg_list[$reg_num]} ) {
  
          #last reg_bit but not at 0 position, add Zero
          if($reg_bit_ptr != -1) {
            $new_line .= ", ";
  
            $add_zero_num = $reg_bit_ptr + 1 ;
            if($add_zero_num<10) {
              $new_line .= " ${add_zero_num}'h0";
            }
            else {
              $new_line .= "${add_zero_num}'h0";
            }
          }
  
          $new_line .= " };\n";
  
        }
        else  {
          $new_line .= ", ";
        }
  
      }
  
      push(@reg_read_line, $new_line);
  
    }
    push(@reg_read_line, "\n"x2);
  
  
    if($#reg_list == 0) {
      $new_line = "assign  ${module_name}_prdata = (rd_$reg_name_align   ?  data_$reg_name_align  : 32'h0000_0000) ; \n";
      push(@reg_read_line, $new_line);
    }
    else  {
      for $reg_num (0..$#reg_list) {
        $reg_name       = $reg_list[$reg_num][0][0];
        $reg_name_align = $reg_list[$reg_num][0][1];
  
        if($reg_num == 0) {
          $new_line = "assign  ${module_name}_prdata = ( rd_$reg_name_align   ?  data_$reg_name_align  : 32'h0000_0000 ) | \n";
        }
        elsif($reg_num == $#reg_list)  {
          $new_line  = " " x (18+$module_name_len);
          $new_line .= "( rd_$reg_name_align   ?  data_$reg_name_align  : 32'h0000_0000 ) ; \n";
        }
        else {
          $new_line  = " " x (18+$module_name_len);
          $new_line .= "( rd_$reg_name_align   ?  data_$reg_name_align  : 32'h0000_0000 ) | \n";
        }
        push(@reg_read_line, $new_line);
      }
    }
    push(@reg_read_line, "\n" x 2);
  
  
    #============================ Write Gen ==================================
    $new_line = "//============================================  REG WRITE  ============================================\n",
    push(@reg_write_line, $new_line);
  
    for $reg_num (0..$#reg_list) {
  
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
  
      $new_line = "// MCU Write Register: $reg_name \n";
      push(@reg_write_line, $new_line);
  
      @reg_all_bit_wacc     = ();
      $reg_one_write_access = 0 ;
      for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
        $reg_bit_wr_access = $reg_list[$reg_num][$reg_bit_num][8];
        $reg_bit_wr_logic  = ($reg_bit_wr_access =~ /ro/) ? 0 : 1;
        push(@reg_all_bit_wacc, $reg_bit_wr_logic);
      }
      $reg_one_write_access = max(@reg_all_bit_wacc);
  
      if($reg_one_write_access) {
  
        $new_line = "always @(posedge ${module_name}_pclk or negedge ${module_name}_rst_n)  begin \n";
        push(@reg_write_line, $new_line);
  
        $new_line = "    if(~${module_name}_rst_n)  begin \n";
        push(@reg_write_line, $new_line);
  
        for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
  
          $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
          $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
          $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
          $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
          $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
          $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
          $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
          $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
          $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
          $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
          $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
          $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
          $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
          $reg_bit_name_len = length($reg_bit_name);
  
          if($reg_bit_wr_access =~ /w/) {
            $new_line  = "        $reg_bit_name_align";
            $new_line .= " " x 7;
            $new_line .= "<= #1 $reg_bit_def";
            $new_line .= " " x (50-length($reg_bit_def));
            $new_line .= ";\n";
            # $new_line .= "<= #1 ${reg_bit_len_align}'h";
            # $new_line .= "$reg_bit_def_hex;\n";
            push(@reg_write_line, $new_line);
          }
  
        }
        $new_line = "    end \n";
        push(@reg_write_line, $new_line);
  
        $new_line = "    else begin \n";
        push(@reg_write_line, $new_line);
  
        for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {
  
          $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
          $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
          $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
          $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
          $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
          $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
          $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
          $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
          $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
          $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
          $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
          $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
          $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
          $byte_end    = POSIX::floor($reg_bit_end/8);
          $byte_start  = POSIX::floor($reg_bit_start/8);
  
          $reg_bit_wr_ptr_end   = $reg_bit_len-1;
          $reg_bit_wr_ptr_start = 0;
  
          if($reg_bit_wr_access =~ /w/) {
            for $byte_ptr (reverse $byte_start..$byte_end) {
  
              $data_ptr_max = ($byte_ptr == $byte_end  ) ? $reg_bit_end   : ($byte_ptr+1)*8 - 1 ;
              $data_ptr_min = ($byte_ptr == $byte_start) ? $reg_bit_start : $byte_ptr*8         ;
              $data_ptr_len = $data_ptr_max - $data_ptr_min + 1;
  
              $reg_bit_wr_ptr_start = $reg_bit_wr_ptr_end - $data_ptr_len + 1;
  
              $data_write = ($data_ptr_len!=1) ? "${module_name}_pwdata[$data_ptr_max:$data_ptr_min]"
                                               : "${module_name}_pwdata[$data_ptr_max]";
  
              $reg_data_name   = ($data_ptr_len!=1) ? "${reg_bit_name}[${reg_bit_wr_ptr_end}:$reg_bit_wr_ptr_start]" :
                                 ($reg_bit_len ==1) ? "${reg_bit_name}" : "${reg_bit_name}[${reg_bit_wr_ptr_end}]"   ;
  
              $reg_data_name  .= " " x ($reg_bit_name_len_max + 9 - length($reg_data_name) );
  
              $new_line  = "        ";
              $new_line .= "$reg_data_name";
  
              $new_line .= "<= #1 ( wr_$reg_name_align && ${module_name}_pstrb[$byte_ptr] ) ? $data_write ";
  
              $new_line .= " " x (24 - length($data_write));
  
              if($reg_bit_wr_access =~ /(rw|wo)/) {
                $reg_def_write = $reg_data_name ;
              }
              elsif($reg_bit_wr_access =~ /w1c/) {
                $reg_def_write  = "${data_ptr_len}'b";
                $reg_def_write .= "0" x $data_ptr_len;
              }
              $new_line .= ": $reg_def_write ;\n";
              push(@reg_write_line, $new_line);
  
              $reg_bit_wr_ptr_end = $reg_bit_wr_ptr_start - 1;
            }
          }
        }
        $new_line = "    end \n";
        push(@reg_write_line, $new_line);
  
        $new_line = "end \n";
        push(@reg_write_line, $new_line);
  
      }
  
      push(@reg_write_line, "\n" x 2);
  
    }
  
  
    #============================ Gen Line ===================================
    push(@gen_line, @module_head_line);
    push(@gen_line, @reg_declare_line);
    push(@gen_line, @reg_assign_line );
    push(@gen_line, @reg_read_line   );
    push(@gen_line, @reg_write_line  );
  
    $new_line = "//=====================================================================================================\n",
    push(@gen_line, $new_line);
  
    push(@gen_line, "\n" x 3);
  
    push(@gen_line, "endmodule \n");
  
    # print @gen_line;
  
  
    #============================ Gen csr.v ==================================
    open (write_file,">:encoding(utf8)", $result_dir.$verilog_filename);
    print write_file @gen_line;
    close write_file;
    print "\n -------- $verilog_filename Generated -------- \n\n";
  } 
  
}

#=========================================================================
sub  module_vdef_export {

  if($gen_type) {
    $v_define_filename = "gen_".$module_name."_def.v";
  }
  else {
    $v_define_filename = "modify_".$module_name."_def.v";
  }

  $v_define_file_exist = -e $result_dir.$v_define_filename;

  if ( $v_define_file_exist ) {
    print "$v_define_filename Exist, OverWrite it ? <y/n> (Default OverWrite): ";
    chomp (my $key_input=<STDIN>);

    if($key_input eq "n") {
      print"\n -------- $v_define_filename No Change !!! -------- \n\n";
      $v_define_gen = 0; 
    }
    else {
      print"\n -------- $v_define_filename OverWrite !!! -------- \n\n";
      $v_define_gen = 1;
    }
  }
  else {
    $v_define_gen = 1 ;
  }

  if($v_define_gen){
  
    @v_def_line_array = ();

    $define_new_line = "//---------------------------------------------------------------------------------\n";
    push(@v_def_line_array, $define_new_line);
  
    $define_new_line = "//".uc($module_name)."\n";
    push(@v_def_line_array, $define_new_line);
  
    for my $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
      $reg_addr_name2 = $reg_addr_align;
      $reg_addr_name2 =~ s/`//g;

      $reg_addr_ofs_hex_str  = "32'h".$reg_one_macro_addr_hash{$reg_name};
  
  
      $define_new_line = "`define   ". $reg_addr_name2. "                     ". $reg_addr_ofs_hex_str. "\n" ;
      push(@v_def_line_array, $define_new_line);
    }
    $define_new_line = "\n";
    push(@v_def_line_array, $define_new_line);
  
    for my $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
      $reg_addr_name2 = $reg_addr_align;
      $reg_addr_name2 =~ s/`//g;
  
      $define_new_line = "`define   ABS_".$reg_addr_name2."                 ( ".$reg_base_name." + ".$reg_addr_align." )\n" ;
      push(@v_def_line_array, $define_new_line);
    }
  
    # print @v_def_line_array;
  
    #============================ Gen def.v ==================================
    open (write_file,">:encoding(utf8)", $result_dir.$v_define_filename);
    print write_file @v_def_line_array;
    close write_file;
    print "\n -------- $v_define_filename Generated -------- \n\n";
  
  }

}

sub  module_hdef_export {
  if($gen_type) {
    $h_define_filename = "gen_".$module_name."_def.h";
  }
  else {
    $h_define_filename = "modify_".$module_name."_def.h";
  }

  $h_define_file_exist = -e $result_dir.$h_define_filename;

  if ( $h_define_file_exist ) {
    print "$h_define_filename Exist, OverWrite it ? <y/n> (Default OverWrite): ";
    chomp (my $key_input=<STDIN>);

    if($key_input eq "n") {
      print"\n -------- $h_define_filename No Change !!! -------- \n\n";
      $h_define_gen = 0; 
    }
    else {
      print"\n -------- $h_define_filename OverWrite !!! -------- \n\n";
      $h_define_gen = 1;
    }
  }
  else {
    $h_define_gen = 1 ;
  }


  if($h_define_gen){
  
    @h_def_line_array = ();

    $define_new_line = "//------------------------------------------------------------------------------\n";
    push(@h_def_line_array, $define_new_line);
  
    $define_new_line = "//".uc($module_name)."\n";
    push(@h_def_line_array, $define_new_line);
  
    $define_new_line = "//------------------------------------------------------------------------------\n";
    push(@h_def_line_array, $define_new_line);
  
    for my $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
      $reg_addr_name2 = $reg_addr_align;
      $reg_addr_name2 =~ s/`//g;
  
      $reg_addr_ofs_hex_str  = "0x".$reg_one_macro_addr_hash{$reg_name};
  
      $define_new_line = "#define   ". $reg_addr_name2. "          ". $reg_addr_ofs_hex_str. "\n" ;
      push(@h_def_line_array, $define_new_line);
    }
    $define_new_line = "\n";
    push(@h_def_line_array, $define_new_line);
  
    for my $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
      $reg_addr_name2 = $reg_addr_align;
      $reg_addr_name2 =~ s/`//g;
      $reg_base_name2 = $reg_base_name;
      $reg_base_name2 =~ s/`//g;
  
      $define_new_line = "#define   ABS_".$reg_addr_name2."      ( ".$reg_base_name2." + ".$reg_addr_name2.")\n" ;
      push(@h_def_line_array, $define_new_line);
    }
  
    #============================ Gen def.v ==================================
    open (write_file,">:encoding(utf8)", $result_dir.$h_define_filename);
    print write_file @h_def_line_array;
    close write_file;
    print "\n -------- $h_define_filename Generated -------- \n\n";
  }

}

#=========================================================================
sub  uvm_excel_export {

  if($gen_type) {
    $excel_filename = "gen_uvm_".$project_name.".xlsx";
  }
  else {
    $excel_filename = "modify_uvm_".$project_name.".xlsx";
  }
  
  $excel_exist = -e $result_dir.$excel_filename;
    
  if ( $excel_exist ) {
    print "$excel_filename Exist, OverWrite it ? <y/n> (Default OverWrite): ";
    chomp ($key_input=<STDIN>);

    if($key_input eq "n") {
      print"\n -------- $excel_filename No Change !!! -------- \n\n";
      $excel_gen = 0; 
    }
    else {
      print"\n -------- $excel_filename OverWrite !!! -------- \n\n";
      $excel_gen = 1;
    }
  }
  else {
    $excel_gen = 1 ;
  }

  if($excel_gen){

    $reg_total_space = 0;

    my $workbook = Excel::Writer::XLSX->new($result_dir.$excel_filename);

    #-------------------------------------------------------------------------------- 
    # Format List 
    #-------------------------------------------------------------------------------- 
    $format_left = $workbook->add_format(
      border => 1,
      valign => 'vcenter',
      align  => 'left' 
    );
    #-------------------------------------------------------------------------------- 

    #-------------------------------------------------------------------------------- 
    # Project worksheet
    #-------------------------------------------------------------------------------- 
    $excel_project_sheet = $workbook->add_worksheet($project_name);
    $excel_project_sheet->set_column( 0, 0, 20 ); 
    $excel_project_sheet->set_column( 1, 1, 20 ); 

    $excel_project_sheet->write('A3' , "system name"  , $format_left );
    $excel_project_sheet->write('B3' , $project_name  , $format_left );
    $excel_project_sheet->write('A4' , "system bytes" , $format_left );
    #-------------------------------------------------------------------------------- 
     
    #-------------------------------------------------------------------------------- 
    # module worksheet
    #-------------------------------------------------------------------------------- 
    $project_cell_row = 4 ;

    foreach $vfile(@vfiles){
      module_rd_parser($vfile);

      $module_excel_handle = $workbook->add_worksheet($module_name);
      uvm_module_excel_export($module_excel_handle);

      $excel_project_sheet->write($project_cell_row, 0, $module_name           , $format_left );
      $excel_project_sheet->write($project_cell_row, 1, "0x".$reg_base_addr_hex, $format_left );

      $project_cell_row = $project_cell_row + 1;

      $reg_total_space = $reg_total_space + $reg_base_space ;
    }

    $excel_project_sheet->write('B4' , $reg_total_space, $format_left );


  }

  print "\n -------- $excel_filename Generated -------- \n\n";
}

sub  uvm_module_excel_export{
  
  $module_sheet = $_[0];

  $cell_row = 2;
  for $reg_num (0..$#reg_list) {
    $reg_name       = $reg_list[$reg_num][0][0];
    $reg_name_align = $reg_list[$reg_num][0][1];
    $reg_addr       = $reg_list[$reg_num][1][0];
    $reg_addr_align = $reg_list[$reg_num][1][1];

    uvm_reg_excel_write($module_sheet, $cell_row);
  }

  $module_sheet->write( $cell_row + 0 , 0 , "block name"    , $format_left );
  $module_sheet->write( $cell_row + 0 , 1 , $module_name    , $format_left );
  $module_sheet->write( $cell_row + 1 , 0 , "block bytes"   , $format_left );
  $module_sheet->write( $cell_row + 1 , 1 , $reg_base_space , $format_left );

  $module_sheet->set_column( 'A:A', 25); 
  $module_sheet->set_column( 'B:B', 23); 
  $module_sheet->set_column( 'D:D', 15); 
  $module_sheet->set_column( 'E:E', 60); 

}

sub  uvm_reg_excel_write{

  $module_reg_sheet = $_[0];
  $start_cell_row   = $_[1];

  $reg_addr_ofs_hex_str  = "0x".$reg_one_macro_addr_hash{$reg_name};

  $module_reg_sheet->write( $start_cell_row+0 , 0 , "register name"                   , $format_left );
  $module_reg_sheet->write( $start_cell_row+0 , 1 , $reg_name                         , $format_left );
  $module_reg_sheet->write( $start_cell_row+1 , 0 , "register address(offset)"        , $format_left );
  $module_reg_sheet->write( $start_cell_row+1 , 1 , $reg_addr_ofs_hex_str             , $format_left );
  $module_reg_sheet->write( $start_cell_row+2 , 0 , "bit"                             , $format_left );
  $module_reg_sheet->write( $start_cell_row+2 , 1 , "definition"                      , $format_left );
  $module_reg_sheet->write( $start_cell_row+2 , 2 , "RW"                              , $format_left );
  $module_reg_sheet->write( $start_cell_row+2 , 3 , "reset value"                     , $format_left );
  $module_reg_sheet->write( $start_cell_row+2 , 4 , "description"                     , $format_left );

  $cell_row = $start_cell_row + 3;

  $reg_bit_ptr = 32;
  $rfu_num     = 0 ;
  for $reg_bit_num (2..$#{$reg_list[$reg_num]}) {

    $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
    $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
    $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
    $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
    $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
    $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
    $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
    $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
    $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
    $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
    $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
    $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
    $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
 
    if( $reg_bit_ptr > ($reg_bit_end+1) ) {
      if(($reg_bit_ptr - $reg_bit_end - 1) == 1) {
        $bit_str          = "["            ;
        $bit_str         .= $reg_bit_ptr-1 ;
        $bit_str         .= "]"            ;
      }
      else {
        $bit_str          = "["            ;
        $bit_str         .= $reg_bit_ptr-1 ;
        $bit_str         .= ":"            ;
        $bit_str         .= $reg_bit_end+1 ;
        $bit_str         .= "]"            ;
      }

      $definition_str   = "rfu".$rfu_num ;
      $rw_str           = "ro"           ;
      $reset_value_str  = "0x0"          ;
      $description_str  = "RFU"          ;
      $rfu_num          = $rfu_num + 1   ;

      $module_reg_sheet->write( $cell_row, 0, $bit_str         , $format_left );
      $module_reg_sheet->write( $cell_row, 1, $definition_str  , $format_left );
      $module_reg_sheet->write( $cell_row, 2, $rw_str          , $format_left );
      $module_reg_sheet->write( $cell_row, 3, $reset_value_str , $format_left );
      $module_reg_sheet->write( $cell_row, 4, $description_str , $format_left );

      $reg_bit_ptr = $reg_bit_end ;
      $cell_row    = $cell_row+1  ;
    }


      if($reg_bit_end == $reg_bit_start) {
        $bit_str = "[$reg_bit_end]" ;
      }
      else {
        $bit_str = "[$reg_bit_end:$reg_bit_start]" ;
      }
      $definition_str   = $reg_bit_name                   ;
      $rw_str           = $reg_bit_wr_access              ;
      $reset_value_str  = "0x$reg_bit_def_hex"            ;
      $description_str  = $reg_bit_descript               ;

      $module_reg_sheet->write( $cell_row, 0, $bit_str         , $format_left );
      $module_reg_sheet->write( $cell_row, 1, $definition_str  , $format_left );
      $module_reg_sheet->write( $cell_row, 2, $rw_str          , $format_left );
      $module_reg_sheet->write( $cell_row, 3, $reset_value_str , $format_left );
      $module_reg_sheet->write( $cell_row, 4, $description_str , $format_left );

      $reg_bit_ptr = $reg_bit_start ;
      $cell_row    = $cell_row+1    ;


    if($reg_bit_num == $#{$reg_list[$reg_num]}) {
      if($reg_bit_ptr > 0) {
        if($reg_bit_ptr == 1) {
          $bit_str = "[0]"            ;
        }
        else {
          $bit_str = "["             ;
          $bit_str .= $reg_bit_ptr-1 ;
          $bit_str .= ":0]"          ;
        }

        $definition_str   = "rfu".$rfu_num ;
        $rw_str           = "ro"           ;
        $reset_value_str  = "0x0"          ;
        $description_str  = "RFU"          ;
        $rfu_num          = $rfu_num + 1   ;

        $module_reg_sheet->write( $cell_row, 0, $bit_str         , $format_left );
        $module_reg_sheet->write( $cell_row, 1, $definition_str  , $format_left );
        $module_reg_sheet->write( $cell_row, 2, $rw_str          , $format_left );
        $module_reg_sheet->write( $cell_row, 3, $reset_value_str , $format_left );
        $module_reg_sheet->write( $cell_row, 4, $description_str , $format_left );

        $reg_bit_ptr = 0             ;
        $cell_row    = $cell_row + 1 ;
      }
    }
  }


  $cell_row = $cell_row + 2 ;

}


sub  read_excel_export {
  if($gen_type) {
    $excel_filename = "gen_read_".$module_name.".xlsx";
  }
  else {
    $excel_filename = "modify_read_".$module_name.".xlsx";
  }

  $excel_exist = -e $result_dir.$excel_filename;
    
  if ( $excel_exist ) {
    print "$excel_filename Exist, OverWrite it ? <y/n> (Default OverWrite): ";
    chomp (my $key_input=<STDIN>);

    if($key_input eq "n") {
      print"\n -------- $excel_filename No Change !!! -------- \n\n";
      $excel_gen = 0; 
    }
    else {
      print"\n -------- $excel_filename OverWrite !!! -------- \n\n";
      $excel_gen = 1;
    }
  }
  else {
    $excel_gen = 1 ;
  }

  if($excel_gen){
    my $workbook = Excel::Writer::XLSX->new($result_dir.$excel_filename);
  
    #---------------------------------  Format List --------------------------------- 
    $format_rfu = $workbook->add_format(); # Add a format
    $format_rfu->set_valign('vcenter');
    $format_rfu->set_align('center');
    $format_rfu->set_border(1);
    $format_rfu->set_bg_color('silver');
  
    $format_center = $workbook->add_format(); # Add a format
    $format_center->set_valign('vcenter');
    $format_center->set_align('center');
    $format_center->set_border(1);
    $format_center->set_italic(1);
  
    $format_center_ni = $workbook->add_format(); # Add a format
    $format_center_ni->set_valign('vcenter');
    $format_center_ni->set_align('center');
    $format_center_ni->set_font('新宋体');
    $format_center_ni->set_border(1);
    $format_center_ni->set_italic(0);
  
    $format_left_ni = $workbook->add_format(); # Add a format
    $format_left_ni->set_valign('vcenter');
    $format_left_ni->set_align('left');
    $format_left_ni->set_font('新宋体');
    $format_left_ni->set_border(1);
    $format_left_ni->set_italic(0);
  
    $format_center_bold = $workbook->add_format(); # Add a format
    $format_center_bold->set_valign('vcenter');
    $format_center_bold->set_align('center');
    $format_center_bold->set_bg_color('#B8CCE4');
    $format_center_bold->set_border(1);
    $format_center_bold->set_bold();
  
    $format_center_bold2 = $workbook->add_format(); # Add a format
    $format_center_bold2->set_valign('vcenter');
    $format_center_bold2->set_align('center');
    $format_center_bold2->set_border(1);
    $format_center_bold2->set_bold();
  
  
  
    $format_left = $workbook->add_format(); # Add a format
    $format_left->set_valign('vcenter');
    $format_left->set_align('left');
    $format_left->set_border(1);
  
    $format_merge_center = $workbook->add_format(
        border => 1,
        valign => 'vcenter',
        align  => 'center',
        italic => 1
    );
    $format_merge_left = $workbook->add_format(
        font   => '新宋体',
        border => 1,
        valign => 'vcenter',
        align  => 'left',
    );
    $format_merge_center_bold = $workbook->add_format(
        border    => 1,
        bold      => 1,
        valign    => 'vcenter',
        align     => 'center',
        bg_color  => '#B8CCE4',
    );
  
    $format_redbold = $workbook->add_format(); # Add a format
    $format_redbold->set_color('red');
    $format_redbold->set_size(14);
    $format_redbold->set_bold();
  
    $format_bluebold = $workbook->add_format(); # Add a format
    $format_bluebold->set_align('left');
    $format_bluebold->set_color('blue');
    $format_bluebold->set_border();
    $format_bluebold->set_size(14);
    $format_bluebold->set_bold();
  
    $format_center_bluebold = $workbook->add_format(); # Add a format
    $format_center_bluebold->set_align('center');
    $format_center_bluebold->set_color('blue');
    $format_center_bluebold->set_border();
    $format_center_bluebold->set_size(14);
    $format_center_bluebold->set_bold();
  
  
    # Add a worksheet
    $reg_list_sheet = $workbook->add_worksheet('reg_list');
  
    # Set Column Width
    $reg_list_sheet->set_column( 0, 1, 35 ); 
    $reg_list_sheet->set_column( 2, 4, 20 ); 
  
    $reg_list_sheet->write('A1 ' , "模块名"     , $format_center_bold    );
    $reg_list_sheet->write('A2 ' , $module_name , $format_center_bluebold);
  
    $reg_list_sheet->merge_range('B1:E1', "寄存器基址"              , $format_center_bold    );
    $reg_list_sheet->merge_range('B2:E2', "32'h".$reg_base_addr_hex , $format_center_bluebold);
  
    $reg_list_sheet->write('A3 ' , "寄存器名"           , $format_center_bold);
    $reg_list_sheet->write('B3 ' , "寄存器地址宏定义"   , $format_center_bold);
    $reg_list_sheet->write('C3 ' , "寄存器地址偏移值"   , $format_center_bold);
    $reg_list_sheet->write('D3 ' , "寄存器地址绝对值"   , $format_center_bold);
    $reg_list_sheet->write('E3 ' , "寄存器默认值"       , $format_center_bold);
  
    for my $reg_num (0..$#reg_list) {
  
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
  
      $reg_name_org = $reg_name ;
      $reg_name_org =~ s/\s//g  ;
  
      $reg_addr_org = $reg_addr ;
      $reg_addr_org =~ s/\s//g  ;
  
      $reg_one_def_bin = "00000000000000000000000000000000";
      $reg_one_def_rfu = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  
      # Add a worksheet
      $reg_one_sheet = $workbook->add_worksheet($reg_name_org);
  
      # Set Column Width
      $reg_one_sheet->set_column( 0, 8, 14.5 ); 
  
      #-------------------------------------------------------------------------------- 
      for my $write_row(0..18) {
        for my $write_col(0..8) {
          $reg_one_sheet->write_blank($write_row, $write_col, $format_rfu);
        }
      }
      
      # Basic Table
      $reg_one_sheet->write('A1 ' , "寄存器名"     , $format_center_bold);
      $reg_one_sheet->write('A2 ' , "地址偏移值"   , $format_center_bold);
      $reg_one_sheet->write('A3 ' , "复位值"       , $format_center_bold);
      $reg_one_sheet->write('A4 ' , "位"           , $format_center_bold);
      $reg_one_sheet->write('A5 ' , "位名"         , $format_center_bold);
      $reg_one_sheet->write('A6 ' , "权限"         , $format_center_bold);
      $reg_one_sheet->write('A7 ' , "复位值"       , $format_center_bold);
      $reg_one_sheet->write('A8 ' , "位"           , $format_center_bold);
      $reg_one_sheet->write('A9 ' , "位名"         , $format_center_bold);
      $reg_one_sheet->write('A10' , "权限"         , $format_center_bold);
      $reg_one_sheet->write('A11' , "复位值"       , $format_center_bold);
      $reg_one_sheet->write('A12' , "位"           , $format_center_bold);
      $reg_one_sheet->write('A13' , "位名"         , $format_center_bold);
      $reg_one_sheet->write('A14' , "权限"         , $format_center_bold);
      $reg_one_sheet->write('A15' , "复位值"       , $format_center_bold);
      $reg_one_sheet->write('A16' , "位"           , $format_center_bold);
      $reg_one_sheet->write('A17' , "位名"         , $format_center_bold);
      $reg_one_sheet->write('A18' , "权限"         , $format_center_bold);
      $reg_one_sheet->write('A19' , "复位值"       , $format_center_bold);
  
      $reg_one_sheet->write('B4 ' , "31"           , $format_center_bold);
      $reg_one_sheet->write('C4 ' , "30"           , $format_center_bold);
      $reg_one_sheet->write('D4 ' , "29"           , $format_center_bold);
      $reg_one_sheet->write('E4 ' , "28"           , $format_center_bold);
      $reg_one_sheet->write('F4 ' , "27"           , $format_center_bold);
      $reg_one_sheet->write('G4 ' , "26"           , $format_center_bold);
      $reg_one_sheet->write('H4 ' , "25"           , $format_center_bold);
      $reg_one_sheet->write('I4 ' , "24"           , $format_center_bold);
      $reg_one_sheet->write('B8 ' , "23"           , $format_center_bold);
      $reg_one_sheet->write('C8 ' , "22"           , $format_center_bold);
      $reg_one_sheet->write('D8 ' , "21"           , $format_center_bold);
      $reg_one_sheet->write('E8 ' , "20"           , $format_center_bold);
      $reg_one_sheet->write('F8 ' , "19"           , $format_center_bold);
      $reg_one_sheet->write('G8 ' , "18"           , $format_center_bold);
      $reg_one_sheet->write('H8 ' , "17"           , $format_center_bold);
      $reg_one_sheet->write('I8 ' , "16"           , $format_center_bold);
      $reg_one_sheet->write('B12' , "15"           , $format_center_bold);
      $reg_one_sheet->write('C12' , "14"           , $format_center_bold);
      $reg_one_sheet->write('D12' , "13"           , $format_center_bold);
      $reg_one_sheet->write('E12' , "12"           , $format_center_bold);
      $reg_one_sheet->write('F12' , "11"           , $format_center_bold);
      $reg_one_sheet->write('G12' , "10"           , $format_center_bold);
      $reg_one_sheet->write('H12' , "9"            , $format_center_bold);
      $reg_one_sheet->write('I12' , "8"            , $format_center_bold);
      $reg_one_sheet->write('B16' , "7"            , $format_center_bold);
      $reg_one_sheet->write('C16' , "6"            , $format_center_bold);
      $reg_one_sheet->write('D16' , "5"            , $format_center_bold);
      $reg_one_sheet->write('E16' , "4"            , $format_center_bold);
      $reg_one_sheet->write('F16' , "3"            , $format_center_bold);
      $reg_one_sheet->write('G16' , "2"            , $format_center_bold);
      $reg_one_sheet->write('H16' , "1"            , $format_center_bold);
      $reg_one_sheet->write('I16' , "0"            , $format_center_bold);
  
      $reg_one_sheet->write('A22' , "位"           , $format_center_bold);
      $reg_one_sheet->write('B22' , "位名"         , $format_center_bold);
      $reg_one_sheet->write('C22' , "权限"         , $format_center_bold);
      $reg_one_sheet->write('D22' , "复位值"       , $format_center_bold);
  
      $reg_one_sheet->merge_range('E22:I22', "功能", $format_merge_center_bold );
  
      # Jump to reg_list
      $reg_num_add4 = $reg_num+4;
      $jump_addr_str = "=HYPERLINK(\"\#reg_list!A"."$reg_num_add4\"".",\"jump to reg_list\")";
      $reg_one_sheet->merge_range('A20:B20', $jump_addr_str, $format_redbold);
      # $reg_one_sheet->merge_range('A20:B20', '=HYPERLINK("#reg_list!A1","jump to reg_list")', $format_redbold);
  
      # reg_bit
      for my $reg_bit_num (2..$#{$reg_list[$reg_num]}) {

        $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
        $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
        $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
        $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
        $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
        $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
        $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
        $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
        $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
        $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
        $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
        $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
        $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
  
        $reg_bit_name_org = $reg_bit_name ;
        $reg_bit_name_org =~ s/\s//g      ;
  
        $reg_bit_name_len = length($reg_bit_name) ;
  
        substr($reg_one_def_bin, 31-$reg_bit_end, $reg_bit_len, $reg_bit_def_bin);
        substr($reg_one_def_rfu, 31-$reg_bit_end, $reg_bit_len, $reg_bit_def_bin);
  
        # Write reg_bit_name/reg_bit_wr
        if($reg_bit_end > 23) {
          if($reg_bit_start > 23){
            if($reg_bit_len>1)  {
              $reg_one_sheet->merge_range( 4, 32-$reg_bit_end, 4, 32-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 5, 32-$reg_bit_end, 5, 32-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 4, 32-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 5, 32-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..$reg_bit_len-1) { $reg_one_sheet->write( 6, 32-$reg_bit_end+$num, '', $format_center ); }
          }
          elsif($reg_bit_start > 15) {  
            if($reg_bit_end == 24) {
              $reg_one_sheet->write( 4, 32-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 5, 32-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->merge_range( 4, 32-$reg_bit_end, 4, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 5, 32-$reg_bit_end, 5, 8, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-32+$reg_bit_end) { $reg_one_sheet->write( 6, 32-$reg_bit_end+$num, '', $format_center ); }
  
            if($reg_bit_start < 23)  {
              $reg_one_sheet->merge_range( 8, 1, 8, 24-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 9, 1, 9, 24-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 8, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 9, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..24-$reg_bit_start-1) { $reg_one_sheet->write( 10, 1+$num, '', $format_center ); }
          }
          elsif($reg_bit_start > 7){
            if($reg_bit_end == 24) {
              $reg_one_sheet->write( 4, 32-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 5, 32-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->merge_range( 4, 32-$reg_bit_end, 4, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 5, 32-$reg_bit_end, 5, 8, $reg_bit_wr_access , $format_merge_center );
            }
  
            for my $num(0..8-32+$reg_bit_end) { $reg_one_sheet->write( 6, 32-$reg_bit_end+$num, '', $format_center ); }
  
            $reg_one_sheet->merge_range( 8, 1, 8, 8, $reg_bit_name_org               , $format_merge_center );
            $reg_one_sheet->merge_range( 9, 1, 9, 8, $reg_bit_wr_access , $format_merge_center );
            for my $num(0..7) { $reg_one_sheet->write( 10, $num+1, '', $format_center ); }
  
            if($reg_bit_start < 15)  {
              $reg_one_sheet->merge_range( 12, 1, 12, 16-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 13, 1, 13, 16-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 12, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 13, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..16-$reg_bit_start-1) { $reg_one_sheet->write( 14, 1+$num, '', $format_center ); }
  
          }
          else{
            if($reg_bit_end == 24) {
              $reg_one_sheet->write( 4, 32-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 5, 32-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->merge_range( 4, 32-$reg_bit_end, 4, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 5, 32-$reg_bit_end, 5, 8, $reg_bit_wr_access , $format_merge_center );
            }
  
            for my $num(0..8-32+$reg_bit_end) { $reg_one_sheet->write( 6, 32-$reg_bit_end+$num, '', $format_center ); }
  
            $reg_one_sheet->merge_range( 8, 1, 8, 8, $reg_bit_name_org               , $format_merge_center );
            $reg_one_sheet->merge_range( 9, 1, 9, 8, $reg_bit_wr_access , $format_merge_center );
            for my $num(0..7) { $reg_one_sheet->write( 10, $num+1, '', $format_center ); }
  
            $reg_one_sheet->merge_range( 12, 1, 12, 8, $reg_bit_name_org               , $format_merge_center );
            $reg_one_sheet->merge_range( 13, 1, 13, 8, $reg_bit_wr_access , $format_merge_center );
            for my $num(0..7) { $reg_one_sheet->write( 14, $num+1, '', $format_center ); }
  
            if($reg_bit_start < 7)  {
              $reg_one_sheet->merge_range( 16, 1, 16, 8-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 17, 1, 17, 8-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 16, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 17, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-$reg_bit_start-1) { $reg_one_sheet->write( 18, 1+$num, '', $format_center ); }
  
          }
        }
  
        elsif($reg_bit_end > 15) {
          if($reg_bit_start > 15){
            if($reg_bit_len>1)  {
              $reg_one_sheet->merge_range( 8, 24-$reg_bit_end, 8, 24-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 9, 24-$reg_bit_end, 9, 24-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 8, 24-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 9, 24-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..$reg_bit_len-1) { $reg_one_sheet->write( 10, 24-$reg_bit_end+$num, '', $format_center ); }
          }
          elsif($reg_bit_start > 7){
            if($reg_bit_end == 16) {
              $reg_one_sheet->write( 8, 24-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 9, 24-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else{
              $reg_one_sheet->merge_range( 8, 24-$reg_bit_end, 8, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 9, 24-$reg_bit_end, 9, 8, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-24+$reg_bit_end) { $reg_one_sheet->write( 10, 24-$reg_bit_end+$num, '', $format_center ); }
  
            if($reg_bit_start < 15)  {
              $reg_one_sheet->merge_range( 12, 1, 12, 16-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 13, 1, 13, 16-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 12, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 13, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..16-$reg_bit_start-1) { $reg_one_sheet->write( 14, 1+$num, '', $format_center ); }
          }
          else{
            if($reg_bit_end == 16) {
              $reg_one_sheet->write( 8, 24-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 9, 24-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->merge_range( 8, 24-$reg_bit_end, 8, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 9, 24-$reg_bit_end, 9, 8, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-24+$reg_bit_end) { $reg_one_sheet->write( 10, 24-$reg_bit_end+$num, '', $format_center ); }
  
            $reg_one_sheet->merge_range( 12, 1, 12, 8, $reg_bit_name_org               , $format_merge_center );
            $reg_one_sheet->merge_range( 13, 1, 13, 8, $reg_bit_wr_access , $format_merge_center );
            for my $num(0..7) { $reg_one_sheet->write( 14, 1+$num, '', $format_center ); }
  
            if($reg_bit_start < 7)  {
              $reg_one_sheet->merge_range( 16, 1, 16, 8-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 17, 1, 17, 8-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 16, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 17, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-$reg_bit_start-1) { $reg_one_sheet->write( 18, 1+$num, '', $format_center ); }
          }
        }
  
        elsif($reg_bit_end > 7) {
          if($reg_bit_start > 7){
            if($reg_bit_len>1)  {
              $reg_one_sheet->merge_range( 12, 16-$reg_bit_end, 12, 16-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 13, 16-$reg_bit_end, 13, 16-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 12, 16-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 13, 16-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..$reg_bit_len-1) { $reg_one_sheet->write( 14, 16-$reg_bit_end+$num, '', $format_center ); }
          }
          else{
            if($reg_bit_end == 8) {
              $reg_one_sheet->write( 12, 16-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 13, 16-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->merge_range( 12, 16-$reg_bit_end, 12, 8, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 13, 16-$reg_bit_end, 13, 8, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-16+$reg_bit_end) { $reg_one_sheet->write( 14, 16-$reg_bit_end+$num, '', $format_center ); }
  
            if($reg_bit_start < 7)  {
              $reg_one_sheet->merge_range( 16, 1, 16, 8-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 17, 1, 17, 8-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 16, 1, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 17, 1, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..8-$reg_bit_start-1) { $reg_one_sheet->write( 18, 1+$num, '', $format_center ); }
          }
        }
  
        else {
            if($reg_bit_len>1)  {
              $reg_one_sheet->merge_range( 16, 8-$reg_bit_end, 16, 8-$reg_bit_start, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->merge_range( 17, 8-$reg_bit_end, 17, 8-$reg_bit_start, $reg_bit_wr_access , $format_merge_center );
            }
            else {
              $reg_one_sheet->write( 16, 8-$reg_bit_end, $reg_bit_name_org               , $format_merge_center );
              $reg_one_sheet->write( 17, 8-$reg_bit_end, $reg_bit_wr_access , $format_merge_center );
            }
            for my $num(0..$reg_bit_len-1) { $reg_one_sheet->write( 18, 8-$reg_bit_end+$num, '', $format_center ); }
        }
  
        $reg_one_sheet->set_row( 22+$reg_bit_num-2, 45 ); 
        if($reg_bit_len == 1) {
          $reg_one_sheet->write( 22+$reg_bit_num-2, 0, $reg_bit_end, $format_center_ni);
        }
        else {
          $reg_one_sheet->write( 22+$reg_bit_num-2, 0, $reg_bit_end.":".$reg_bit_start, $format_center_ni);
        }
        $reg_one_sheet->write( 22+$reg_bit_num-2, 1, $reg_bit_name_org, $format_left_ni);
        $reg_one_sheet->write( 22+$reg_bit_num-2, 2, $reg_bit_wr_access, $format_center_ni);
        $reg_one_sheet->write( 22+$reg_bit_num-2, 3, $reg_bit_len."\'h".$reg_bit_def_hex, $format_left_ni);
        $reg_one_sheet->merge_range( 22+$reg_bit_num-2, 4, 22+$reg_bit_num-2, 8, $reg_bit_descript, $format_merge_left);
  
      }
  
      $reg_one_def_dec     = oct("0b".$reg_one_def_bin);
      $reg_one_def_hex     = sprintf("%x", $reg_one_def_dec);
      $reg_one_def_hex     = "0"x(8-length($reg_one_def_hex)).$reg_one_def_hex;
      $reg_one_def_hex_str = "32'h".$reg_one_def_hex;
  
      # push(@reg_one_def_c_str, $reg_one_def_hex);
  
      for my $byte_num(0..3){
        $write_row = 6 + 4*$byte_num;
        for my $bit_num(0..7) {
          $write_col = 1 + $bit_num;
          $write_val = substr $reg_one_def_rfu, $bit_num + 8*$byte_num, 1;
          if($write_val ne "x") {
            $reg_one_sheet->write( $write_row, $write_col, $write_val, $format_center);
          }
        }
      } 
  
      $reg_ofs_addr_hex     = $reg_one_macro_addr_hash{$reg_name}     ;
      $reg_ofs_addr_dec     = hex($reg_ofs_addr_hex)                  ;
      $reg_base_addr_dec    = hex($reg_base_addr_hex)                 ;
      $reg_abs_addr_dec     = $reg_base_addr_dec + $reg_ofs_addr_dec  ;
      $reg_abs_addr_hex     = sprintf("%0x", $reg_abs_addr_dec)       ;
  
      $reg_ofs_addr_hex_str = "32'h".uc($reg_ofs_addr_hex)            ;
      $reg_abs_addr_hex_str = "32'h".uc($reg_abs_addr_hex)            ;
  
      #reg_list
      $str_hyperlink = "=HYPERLINK(\"#".$reg_name_org."!A1\",\"$reg_name_org\")";
      $reg_list_sheet->write($reg_num+3, 0, $str_hyperlink        , $format_bluebold );
      $reg_list_sheet->write($reg_num+3, 1, $reg_addr_align       , $format_center_ni);
      $reg_list_sheet->write($reg_num+3, 2, $reg_ofs_addr_hex_str , $format_center_ni);
      $reg_list_sheet->write($reg_num+3, 3, $reg_abs_addr_hex_str , $format_center_ni);
      $reg_list_sheet->write($reg_num+3, 4, $reg_one_def_hex_str  , $format_center_ni);
  
      #reg_one
      $reg_one_sheet->merge_range('B1:I1', $reg_name_org         , $format_merge_center );
      $reg_one_sheet->merge_range('B2:I2', $reg_ofs_addr_hex_str , $format_merge_center );
      $reg_one_sheet->merge_range('B3:I3', $reg_one_def_hex_str  , $format_merge_center );
  
    }
  
    print "\n -------- $excel_filename Generated -------- \n\n";
  
  }



}

sub  module_ctest_export {

  if($gen_type) {
    $ctest_filename = "gen_".$module_name."_ctest.c";
  }
  else {
    $ctest_filename = "modify_".$module_name."_ctest.c";
  }

  $ctest_file_exist = -e $result_dir.$ctest_filename;

  if ( $ctest_file_exist ) {
    print "$ctest_filename Exist, OverWrite it ? <y/n> (Default OverWrite): ";
    chomp (my $key_input=<STDIN>);

    if($key_input eq "n") {
      print"\n -------- $ctest_filename No Change !!! -------- \n\n";
      $ctest_gen = 0; 
    }
    else {
      print"\n -------- $ctest_filename OverWrite !!! -------- \n\n";
      $ctest_gen = 1;
    }
  }
  else {
    $ctest_gen = 1 ;
  }

  if($ctest_gen){
  
    @ctest_line_array = ();

    $ctest_new_line = "void reg_test(void)  { \n\n";
    push(@ctest_line_array, $ctest_new_line);

    for my $reg_num (0..$#reg_list) {
      $reg_name       = $reg_list[$reg_num][0][0];
      $reg_name_align = $reg_list[$reg_num][0][1];
      $reg_addr       = $reg_list[$reg_num][1][0];
      $reg_addr_align = $reg_list[$reg_num][1][1];
      $reg_addr_name2 = $reg_addr_align;
      $reg_addr_name2 =~ s/`//g;

      $reg_one_def_bin   = "00000000000000000000000000000000";

      $reg_one_w1_access = "00000000000000000000000000000000";
      $reg_one_w0_access = "00000000000000000000000000000000";
      $reg_one_r1_access = "00000000000000000000000000000000";
      $reg_one_r0_access = "00000000000000000000000000000000";
      for my $reg_bit_num (2..$#{$reg_list[$reg_num]}) {

        $reg_bit_name         = $reg_list[$reg_num][$reg_bit_num][ 0];
        $reg_bit_end          = $reg_list[$reg_num][$reg_bit_num][ 1];
        $reg_bit_start        = $reg_list[$reg_num][$reg_bit_num][ 2];
        $reg_bit_def          = $reg_list[$reg_num][$reg_bit_num][ 3];
        $reg_bit_len          = $reg_list[$reg_num][$reg_bit_num][ 4];
        $reg_bit_len_m1       = $reg_list[$reg_num][$reg_bit_num][ 5];
        $reg_bit_def_bin      = $reg_list[$reg_num][$reg_bit_num][ 6];
        $reg_bit_def_hex      = $reg_list[$reg_num][$reg_bit_num][ 7];
        $reg_bit_wr_access    = $reg_list[$reg_num][$reg_bit_num][ 8];
        $reg_bit_name_align   = $reg_list[$reg_num][$reg_bit_num][ 9];
        $reg_bit_len_align    = $reg_list[$reg_num][$reg_bit_num][10];
        $reg_bit_len_m1_align = $reg_list[$reg_num][$reg_bit_num][11];
        $reg_bit_descript     = $reg_list[$reg_num][$reg_bit_num][12];
 
        $reg_bit_name_len     = length($reg_bit_name) ;

        substr($reg_one_def_bin, 31-$reg_bit_end, $reg_bit_len, $reg_bit_def_bin);

        if($reg_bit_wr_access =~ /ro/) {
          $reg_bit_w1_access = "0" x $reg_bit_len ;
          $reg_bit_w0_access = "0" x $reg_bit_len ;
        }
        if($reg_bit_wr_access =~ /wo|rw/) {
          $reg_bit_w1_access = "1" x $reg_bit_len ;
          $reg_bit_w0_access = "1" x $reg_bit_len ;
        }
        if($reg_bit_wr_access =~ /w1c/) {
          $reg_bit_w1_access = "0" x $reg_bit_len ;
          $reg_bit_w0_access = "0" x $reg_bit_len ;
        }
        substr($reg_one_w1_access, 31-$reg_bit_end, $reg_bit_len, $reg_bit_w1_access);
        substr($reg_one_w0_access, 31-$reg_bit_end, $reg_bit_len, $reg_bit_w0_access);

        if($reg_bit_wr_access =~ /wo|w1c/) {
          $reg_bit_r1_access = "0" x $reg_bit_len ;
          $reg_bit_r0_access = "1" x $reg_bit_len ;
        }
        if($reg_bit_wr_access =~ /ro|rw/) {
          $reg_bit_r1_access = "1" x $reg_bit_len ;
          $reg_bit_r0_access = "1" x $reg_bit_len ;
        }
        substr($reg_one_r1_access, 31-$reg_bit_end, $reg_bit_len, $reg_bit_r1_access);
        substr($reg_one_r0_access, 31-$reg_bit_end, $reg_bit_len, $reg_bit_r0_access);

      }

      $reg_one_w1_dec     = oct("0b".$reg_one_w1_access)     ;
      $reg_one_w0_dec     = oct("0b".$reg_one_w0_access)     ;
      $reg_one_r1_dec     = oct("0b".$reg_one_r1_access)     ;
      $reg_one_r0_dec     = oct("0b".$reg_one_r0_access)     ;
      $reg_one_w1_hex     = sprintf("%08x", $reg_one_w1_dec) ;
      $reg_one_w0_hex     = sprintf("%08x", $reg_one_w0_dec) ;
      $reg_one_r1_hex     = sprintf("%08x", $reg_one_r1_dec) ;
      $reg_one_r0_hex     = sprintf("%08x", $reg_one_r0_dec) ;
      $reg_one_w1_str     = "0x".uc($reg_one_w1_hex)         ;
      $reg_one_w0_str     = "0x".uc($reg_one_w0_hex)         ;
      $reg_one_r1_str     = "0x".uc($reg_one_r1_hex)         ;
      $reg_one_r0_str     = "0x".uc($reg_one_r0_hex)         ;

      $reg_one_def_dec     = oct("0b".$reg_one_def_bin);
      $reg_one_def_hex     = sprintf("%x", $reg_one_def_dec);
      $reg_one_def_hex     = "0"x(8-length($reg_one_def_hex)).$reg_one_def_hex;
  
      # print "  c, $reg_num, $reg_name: $reg_one_def_c_str[$reg_num] \n";
      $ctest_new_line  = "  reg_one_test(\"". uc($reg_name_align). "\", ABS_".$reg_addr_name2.", 0x" ;
      $ctest_new_line .= $reg_one_def_hex.", " ;
      $ctest_new_line .= $reg_one_w1_str.", ".$reg_one_w0_str.", ".$reg_one_r1_str.", ".$reg_one_r0_str." );\n";
      push(@ctest_line_array, $ctest_new_line);

    }

    $ctest_new_line = "\n}\n\n";
    push(@ctest_line_array, $ctest_new_line);

    #============================ Gen reg_test.c ==================================
    open (write_file,">:encoding(utf8)", $result_dir.$ctest_filename);
    print write_file @ctest_line_array;
    close write_file;
    print "\n -------- $ctest_filename Generated -------- \n\n";
  
  }

}


# print ("reg_one: @reg_bit \n");
#
#
