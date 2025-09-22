<script lang="ts">
	import './common.css';
	import { onMount } from 'svelte';
	
	onMount(() => {
		document.body.classList.add('sg-theme');
	});
</script>

<div class="sg-container">
	<header class="sg-header">
		<h1>SvelteKit Demo Application</h1>
	</header>
	
	<main class="sg-content">
		<slot />
	</main>
	
	<footer class="sg-footer">
		<p>&copy; 2025 Sourcegraph Revenue Team</p>
	</footer>
</div>
