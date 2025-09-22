<script lang="ts">
	// Page metadata
	import { page } from '$app/stores';
</script>

<svelte:head>
	<title>Home - SvelteKit Demo</title>
</svelte:head>

<section class="sg-welcome">
	<h2>Welcome to the SvelteKit Demo Application!</h2>
	
	<p class="sg-muted">
		This is a demonstration application built with SvelteKit and modern web technologies.
	</p>
	
	<div class="sg-features">
		<article class="sg-card">
			<h3>🚀 SvelteKit Framework</h3>
			<p>Built with Svelte's full-stack framework for building fast, reactive web applications.</p>
		</article>
		
		<article class="sg-card">
			<h3>🎨 Component-Based UI</h3>
			<p>Using Svelte components for dynamic, maintainable user interface development.</p>
		</article>
	</div>

	<section class="sg-center" style="margin-top: var(--sg-space-12)">
		<h3>Getting Started</h3>
		<p>This application demonstrates the power of SvelteKit for server-side rendering and client-side interactivity.</p>
		<p>Explore the codebase to see how routes, components, and styling work together seamlessly.</p>
	</section>
</section>
