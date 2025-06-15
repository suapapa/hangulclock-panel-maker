<script>
	export let name;

	// 패널 배열 문자열
	const panelArray = `
	열한다세네
	두여섯일곱
	여덟아홉시
	자정이삼십
	사오십오분
	`;

	// 상태 변수 선언
	let panelWidthMM = 170; // mm
	let panelHeightMM = 170; // mm
	let margin = 10;
	let yOffset = 0;
	let dpi = "300"; // 문자열로 선언

	// mm → px 변환 함수
	function mmToPx(mm, dpi) {
		return Math.round((mm / 25.4) * Number(dpi));
	}

	// 캔버스 참조
	let canvasEl;

	// 캔버스 크기 동기화 및 2D 컨텍스트 준비
	$: canvasWidth = mmToPx(panelWidthMM, dpi);
	$: canvasHeight = mmToPx(panelHeightMM, dpi);
	$: ctx = canvasEl ? canvasEl.getContext('2d') : null;

	// 캔버스 초기화 (예시: 배경색만 채우기)
	$: if (ctx) {
		ctx.clearRect(0, 0, canvasWidth, canvasHeight);
		ctx.fillStyle = '#f8f8f8';
		ctx.fillRect(0, 0, canvasWidth, canvasHeight);
		// (여기에 실제 시계 패널 그리기 로직이 추가될 예정)
	}
</script>

<main>
	<h1>한글 시계 패널 설정</h1>
	<form autocomplete="off">
		<label>
			패널 가로(mm):
			<input type="number" bind:value={panelWidthMM} min="10" max="500" required />
		</label>
		<label>
			패널 세로(mm):
			<input type="number" bind:value={panelHeightMM} min="10" max="500" required />
		</label>
		<label>
			DPI:
			<select bind:value={dpi} class="dpi-select">
				<option value="150">150</option>
				<option value="200">200</option>
				<option value="300">300</option>
				<option value="600">600</option>
				<option value="1200">1200</option>
			</select>
		</label>
		<label>
			여백(px):
			<input type="number" bind:value={margin} min="0" max="100" required />
		</label>
		<label>
			y-offset(px):
			<input type="number" bind:value={yOffset} min="-100" max="100" required />
		</label>
		<!-- 추가 입력 항목 필요시 여기에 -->
	</form>

	<div style="margin-top:2em;">
		<h2>미리보기 (설정값)</h2>
		<ul>
			<li>패널 가로: {panelWidthMM}mm ({canvasWidth}px)</li>
			<li>패널 세로: {panelHeightMM}mm ({canvasHeight}px)</li>
			<li>DPI: {dpi}</li>
			<li>여백: {margin}px</li>
			<li>y-offset: {yOffset}px</li>
		</ul>
	</div>

	<div style="margin-top:2em;">
		<h2>패널 캔버스 미리보기</h2>
		<canvas
			bind:this={canvasEl}
			width={canvasWidth}
			height={canvasHeight}
			style="border:1px solid #aaa; background:#f8f8f8; max-width:100%; height:auto; display:block; margin:0 auto;"
		></canvas>
	</div>
</main>

<style>
	main {
		text-align: left;
		padding: 1em;
		max-width: 400px;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		font-size: 2em;
		font-weight: 700;
		margin-bottom: 1em;
	}

	form label {
		display: block;
		margin-bottom: 1em;
	}

	input[type="number"], select.dpi-select {
		width: 100%;
		font-family: inherit;
		font-size: inherit;
		padding: 0.4em;
		margin: 0 0 0.5em 0;
		box-sizing: border-box;
		border: 1px solid #ccc;
		border-radius: 2px;
	}
</style>