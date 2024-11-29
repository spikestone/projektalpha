class SupabaseOptions {
  final String url;
  final String anonKey;

  SupabaseOptions({
    required this.url,
    required this.anonKey,
  });
}

final SupabaseOptions supabaseOptions = SupabaseOptions(
  url: 'https://fpmjwpmuxmpqxtrgbjco.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwbWp3cG11eG1wcXh0cmdiamNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI4MzQ4MzksImV4cCI6MjA0ODQxMDgzOX0.4O8EUaUkmmmMU88xspK8qNlEz149IaEazfXZbq3rjyU',
);
