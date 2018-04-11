import com.maxeler.maxcompiler.v2.kernelcompiler.Kernel;
import com.maxeler.maxcompiler.v2.kernelcompiler.KernelParameters;
import com.maxeler.maxcompiler.v2.kernelcompiler.stdlib.core.Count;
import com.maxeler.maxcompiler.v2.kernelcompiler.stdlib.core.Count.Counter;
import com.maxeler.maxcompiler.v2.kernelcompiler.stdlib.core.Count.WrapMode;
import com.maxeler.maxcompiler.v2.kernelcompiler.types.base.DFEVar;

class TrainingExerciseKernel extends Kernel {

  TrainingExerciseKernel(KernelParameters parameters) {
    super(parameters);

    DFEVar x = io.input("x", dfeFloat(8, 24));
    DFEVar maxN = io.scalarInput("n", dfeUInt(32));
   
    Count.Params params = control.count.makeParams(32).withMax(maxN);
    Counter counter = control.count.makeCounter(params);

    DFEVar prev = stream.offset(x, -1);
    DFEVar next = stream.offset(x, 1);
    DFEVar sum = prev + x + next;
    DFEVar result = counter.getCount().eq(0) | counter.getCount().eq(maxN - 1) ? 0 : sum / 3;

    io.output("y", result, dfeFloat(8, 24));
  }
}

