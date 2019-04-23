 
set hwdsgn [open_hw_design ../HDF/design_1_wrapper.hdf]
generate_app -hw $hwdsgn -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir fsbl
quit
