#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class RandomMetaCTFChallenge < StringGenerator
  attr_accessor :difficulty

  def initialize
    super
    self.module_name = 'Random Wordpress Version Generator'
    self.difficulty = ''
  end


  def get_options_array
    super + [['--difficulty', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--difficulty'
      self.difficulty << arg;
    end
  end

  def generate

    # TODO : run through the challenges and adjust difficulty to something more appropriate

    src_angr = [
        {:difficulty => 'medium', :name => 'src_angr/00_angr_find'},
        {:difficulty => 'medium', :name => 'src_angr/01_angr_avoid'},
        {:difficulty => 'medium', :name => 'src_angr/02_angr_find_condition'},
        {:difficulty => 'medium', :name => 'src_angr/03_angr_symbolic_registers'},
        {:difficulty => 'medium', :name => 'src_angr/04_angr_symbolic_stack'},
        {:difficulty => 'medium', :name => 'src_angr/05_angr_symbolic_memory'},
        {:difficulty => 'medium', :name => 'src_angr/06_angr_symbolic_dynamic_memory'},
        {:difficulty => 'medium', :name => 'src_angr/07_angr_symbolic_file'},
        {:difficulty => 'medium', :name => 'src_angr/08_angr_constraints'},
        {:difficulty => 'hard', :name => 'src_angr/09_angr_hooks'},
        {:difficulty => 'hard', :name => 'src_angr/10_angr_simprocedures'},
        {:difficulty => 'hard', :name => 'src_angr/11_angr_sim_scanf'},
        {:difficulty => 'hard', :name => 'src_angr/12_angr_veritesting'},
        {:difficulty => 'hard', :name => 'src_angr/13_angr_static_binary'},
        {:difficulty => 'hard', :name => 'src_angr/14_angr_shared_library'},
        # TODO: Replacing 'Good Job with a printflag(); call requires more thought for task 15 - omit for now
        # '{:difficulty => 'easy', :name => 'src_angr/15_angr_arbitrary_read'},
        {:difficulty => 'hard', :name => 'src_angr/16_angr_arbitrary_write'},
        {:difficulty => 'hard', :name => 'src_angr/17_angr_arbitrary_jump'},
    ]

    src_csp = [
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch1_Ltrace'},
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch1_Readelf'},
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch2_01_Endian'},
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch2_01_Showkey'},
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch2_03_IntOverflow'},
        {:difficulty => 'easy', :name => 'src_csp/Ch1-2/Ch2_03_TwosComplement'},
        {:difficulty => 'medium', :name => 'src_csp/Ch1-2/Ch2_03_XorInt'},
        {:difficulty => 'medium', :name => 'src_csp/Ch1-2/Ch2_05_FloatConvert'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format0_Leak'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format1_LeakDollar'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format2_nCorruptKey'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format3_nWriteKey'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format4_nWriteFnP'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format5_nTargetWrite'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3-ExtraFormatStr/Ch3_Format6_PLTHijack'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_00_GdbIntro'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_00_GdbRegs'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_00_GdbSetmem'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_01_GdbPractice'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_02_AsciiInstr'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_04_FnPointer'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_04_LinkedList'},
        {:difficulty => 'medium', :name => 'src_csp/Ch3.1-3.5/Ch3_05_XorLong'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.1-3.5/Ch3_05_XorStr'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_06_Conditionals'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_06_LoopMulti'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_06_SwitchTable'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_FloatReturn'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_ParamsRegs'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_ParamsStack'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_SegvBacktrace'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_StaticInt'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.6-3.7/Ch3_07_StaticStrcmp'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_07_CanaryBypass'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_07_HijackPLT'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_07_ScanfOverflow'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_07_StackSmash'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_08_2DArrays'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_08_Matrix'},
        {:difficulty => 'hard', :name => 'src_csp/Ch3.7-3.9/Ch3_09_Structs'},
        {:difficulty => 'hard', :name => 'src_csp/Ch5-8/Ch5_08_LoopUnroll'},
        {:difficulty => 'hard', :name => 'src_csp/Ch5-8/Ch7_13_LdPreloadGetUID'},
        {:difficulty => 'hard', :name => 'src_csp/Ch5-8/Ch8_05_PsSignals'},
        {:difficulty => 'hard', :name => 'src_csp/Ch5-8/Ch8_05_Signals'},
    ]

    src_malware = [
        {:difficulty => 'easy', :name => 'src_malware/Ch01-08/Ch01StatA_Readelf'},
        {:difficulty => 'easy', :name => 'src_malware/Ch01-08/Ch03DynA_Ltrace'},
        {:difficulty => 'easy', :name => 'src_malware/Ch01-08/Ch04x86_AsciiInstr'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch04x86_AsciiStrcmp'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch06CAsm_Conditionals'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch06CAsm_LinkedList'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch06CAsm_LoopMulti'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch06CAsm_SwitchTable'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_GdbIntro'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_GdbParams'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_GdbPractice'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_GdbRegs'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_GdbSetmem'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_InputFormat'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_Radare2Intro1'},
        {:difficulty => 'medium', :name => 'src_malware/Ch01-08/Ch08Dbg_Radare2Intro2'},
        {:difficulty => 'hard', :name => 'src_malware/Ch01-08/Ch08Dbg_StaticInt'},
        {:difficulty => 'hard', :name => 'src_malware/Ch01-08/Ch08Dbg_StaticRE'},
        {:difficulty => 'hard', :name => 'src_malware/Ch01-08/Ch08Dbg_StaticStrcmp'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch11MalBeh_HijackPLT'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch11MalBeh_LdPreloadGetUID'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch11MalBeh_LdPreloadRand'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch11MalBeh_NetcatShovel'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch12Covert_ForkFollow'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch12Covert_ForkPipe'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch13DataEnc_BaseEnc'},
        {:difficulty => 'hard', :name => 'src_malware/Ch11-13/Ch13DataEnc_XorEnc'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch15AntiDis_FakeCallInt'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch15AntiDis_FakeCond'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch15AntiDis_FakeMetaConds'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch15AntiDis_InJmp'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch15AntiDis_PushRet'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_BypassPtrace'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_GdbCheckTrace'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_Int3Scan'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_SigtrapCheck'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_SigtrapEntangle'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_SigtrapHijack'},
        {:difficulty => 'hard', :name => 'src_malware/Ch15-16/Ch16AntiDbg_TimeCheck'},
        {:difficulty => 'hard', :name => 'src_malware/Ch18-21/Ch18PackUnp_UnpackEasy'},
        {:difficulty => 'hard', :name => 'src_malware/Ch18-21/Ch18PackUnp_UnpackGdb'},
        {:difficulty => 'hard', :name => 'src_malware/Ch18-21/Ch21x64_ParamsRegs'},
        {:difficulty => 'hard', :name => 'src_malware/Ch18-21/Ch21x64_ParamsStack'},
    ]

    challenges = src_angr + src_csp + src_malware

    # Select based on difficulty

    challenges.delete_if do |challenge|
        challenge[:difficulty] != self.difficulty
    end

    challenge = challenges.sample
    outputs << challenge[:name]

  end

end

RandomMetaCTFChallenge.new.run