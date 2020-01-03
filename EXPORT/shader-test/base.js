
function fors(value) {
	return value ? "Succeeded" : "Failed";
}

export function mapShaderTypeName(gl, type) {
  if (type == gl.VERTEX_SHADER) return "Vertex";
  if (type == gl.FRAGMENT_SHADER) return "Fragment";
  return "Unknown";
}

export function createShader(gl, type, source, debugName) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  var t0 = performance.now();
  gl.compileShader(shader);
  var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
  var t1 = performance.now();
  
  console.log(`${fors(success)} compiling ${mapShaderTypeName(gl, type)} shader ${type} named ${debugName} in ${t1 - t0} ms`);

  if (success) {
    return shader;
  }
  else {
	console.log("INFOLOG: " + gl.getShaderInfoLog(shader));
	gl.deleteShader(shader);
	return null;
  }
}

export function createProgram(gl, vs, fs, debugName) {
  //performance.mark("createShader:"+debugName);
  var program = gl.createProgram();
  gl.attachShader(program, vs);
  gl.attachShader(program, fs);
  var t0 = performance.now();
  gl.linkProgram(program);
  var t1 = performance.now();
  
  var success = gl.getProgramParameter(program, gl.LINK_STATUS);
  console.log(`${fors(success)} linking program named ${debugName} in ${t1 - t0} ms`);
  if (success) {
	  const numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
	  const numAttributes = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES);
  }
  else {
	console.log("INFOLOG: " + gl.getProgramInfoLog(program));
	gl.deleteProgram(program)
	program = null
  }
  //performance.mark("createShaderEnd:"+debugName);
  //console.log(`createProgram ${debugName} ms: ${t1 - t0}`);
  return program;
}

export function loadProgramFromFilepaths(gl, vs_filepath, fs_filepath, debugName, cb = null) {
	const filename_rx = /(\\|\/)/g
    return Promise.all([
        fetch(vs_filepath).then(vs_file => vs_file.text()),
        fetch(fs_filepath).then(fs_file => fs_file.text())
    ]).then(xs => {
        let vs_text = xs[0]
        let fs_text = xs[1]
        let vs = createShader(gl, gl.VERTEX_SHADER, vs_text, vs_filepath.split(filename_rx).pop());
        let fs = createShader(gl, gl.FRAGMENT_SHADER, fs_text, fs_filepath.split(filename_rx).pop());
        let prog = createProgram(gl, vs, fs, debugName);
        if (cb) {
            cb(prog);
        }
    });
}