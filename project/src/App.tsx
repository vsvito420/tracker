import React, { useState, useEffect, useRef } from 'react';
import { Calendar, Code, Layout, Link, List, Moon, Sun, FolderOpen, ChevronUp, ChevronDown } from 'lucide-react';

interface TimeEntry {
  completed: boolean;
  startTime: string;
  endTime: string;
  title: string;
  link: string;
  subTasks: string[];
  date: string;
}

function App() {
  const [entries, setEntries] = useState<TimeEntry[]>([]);
  const [showCode, setShowCode] = useState(false);
  const [view, setView] = useState('timeline');
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
  const timelineRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    setIsDarkMode(prefersDark);
  }, []);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', isDarkMode);
  }, [isDarkMode]);

  useEffect(() => {
    // Scroll to bottom initially
    if (timelineRef.current) {
      timelineRef.current.scrollTop = timelineRef.current.scrollHeight;
    }
  }, [entries]);

  const parseTimeEntry = (line: string, date: string) => {
    const regex = /- \[([ x])\] (\d{2}:\d{2}) - (\d{2}:\d{2}) (?:####\s*)?(?:\[(.*?)\]\((.*?)\)|(.*))/;
    const match = line.match(regex);
    
    if (match) {
      return {
        completed: match[1] === 'x',
        startTime: match[2],
        endTime: match[3],
        title: match[4] || match[6] || '',
        link: match[5] || '',
        subTasks: [],
        date,
      };
    }
    return null;
  };

  const parseDayPlanner = (text: string) => {
    const lines = text.split('\n');
    const parsedEntries = [];
    let currentEntry = null;

    lines.forEach(line => {
      if (line.trim().startsWith('- [')) {
        if (currentEntry) {
          parsedEntries.push(currentEntry);
        }
        currentEntry = parseTimeEntry(line, new Date().toISOString().split('T')[0]);
      } else if (currentEntry && line.trim().startsWith('-')) {
        currentEntry.subTasks.push(line.trim().substring(2));
      }
    });

    if (currentEntry) {
      parsedEntries.push(currentEntry);
    }

    setEntries(parsedEntries);
  };

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files || []);
    setSelectedFiles(files);

    // Filter for markdown files with the correct naming pattern
    const markdownFiles = files.filter(file => {
      const pattern = /^\d{4}-\d{2}-\d{2}-.+\.md$/;
      return pattern.test(file.name);
    });

    // Sort files by date (newest first)
    markdownFiles.sort((a, b) => {
      const dateA = a.name.split('-').slice(0, 3).join('-');
      const dateB = b.name.split('-').slice(0, 3).join('-');
      return dateB.localeCompare(dateA);
    });

    // Read and parse all files
    const allEntries = [];
    for (const file of markdownFiles) {
      const content = await file.text();
      const lines = content.split('\n');
      const parsedEntries = [];
      let currentEntry = null;

      // Extract date from filename
      const date = file.name.split('-').slice(0, 3).join('-');

      lines.forEach(line => {
        if (line.trim().startsWith('- [')) {
          if (currentEntry) {
            parsedEntries.push(currentEntry);
          }
          currentEntry = parseTimeEntry(line, date);
        } else if (currentEntry && line.trim().startsWith('-')) {
          currentEntry.subTasks.push(line.trim().substring(2));
        }
      });

      if (currentEntry) {
        parsedEntries.push(currentEntry);
      }

      allEntries.push(...parsedEntries);
    }

    setEntries(allEntries);
  };

  const scrollTimeline = (direction: 'up' | 'down') => {
    if (timelineRef.current) {
      const scrollAmount = 300; // Adjust this value to control scroll distance
      const newScrollTop = timelineRef.current.scrollTop + (direction === 'up' ? -scrollAmount : scrollAmount);
      timelineRef.current.scrollTo({
        top: newScrollTop,
        behavior: 'smooth'
      });
    }
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const days = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
    const months = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
    
    return `${days[date.getDay()]}, ${date.getDate()}. ${months[date.getMonth()]} ${date.getFullYear()}`;
  };

  const TimelineEntry = ({ entry }: { entry: TimeEntry }) => (
    <div className="flex gap-4 group relative">
      <div className="flex flex-col items-center">
        <div className="text-sm font-medium text-gray-500 dark:text-gray-400 w-16">
          {entry.startTime}
        </div>
        <div className="w-px h-full bg-gray-200 dark:bg-gray-700 group-last:hidden absolute top-6 left-8 bottom-0" />
      </div>
      <div className="flex-1 pb-8">
        <div className={`bg-white dark:bg-gray-800 rounded-lg border p-4 shadow-sm transition-all duration-200 hover:shadow-md ${
          entry.completed ? 'border-green-500 dark:border-green-600' : ''
        }`}>
          <div className="flex items-start gap-3">
            <input 
              type="checkbox" 
              checked={entry.completed}
              onChange={() => {}}
              className="mt-1 h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <div className="flex-1">
              {entry.link ? (
                <a 
                  href={entry.link}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-500 hover:text-blue-600 flex items-center gap-1 font-medium"
                >
                  {entry.title}
                  <Link className="w-4 h-4" />
                </a>
              ) : (
                <span className="font-medium text-gray-900 dark:text-gray-100">{entry.title}</span>
              )}
              {entry.subTasks.length > 0 && (
                <ul className="mt-2 space-y-1">
                  {entry.subTasks.map((task, index) => (
                    <li key={index} className="text-gray-600 dark:text-gray-400 text-sm flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-gray-400 dark:bg-gray-500"></span>
                      {task}
                    </li>
                  ))}
                </ul>
              )}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400 font-medium">
              {entry.endTime}
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const BlockView = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {entries.map((entry, index) => (
        <div key={index} className="bg-white dark:bg-gray-800 rounded-lg border p-4 shadow-sm hover:shadow-md transition-all duration-200">
          <div className="flex justify-between items-start mb-3">
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                checked={entry.completed}
                onChange={() => {}}
                className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="text-sm font-medium text-gray-500 dark:text-gray-400">
                {entry.startTime} - {entry.endTime}
              </span>
            </div>
          </div>
          {entry.link ? (
            <a 
              href={entry.link}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-500 hover:text-blue-600 flex items-center gap-1 font-medium mb-2"
            >
              {entry.title}
              <Link className="w-4 h-4" />
            </a>
          ) : (
            <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-2">{entry.title}</h3>
          )}
          {entry.subTasks.length > 0 && (
            <ul className="space-y-1">
              {entry.subTasks.map((task, idx) => (
                <li key={idx} className="text-gray-600 dark:text-gray-400 text-sm flex items-center gap-2">
                  <span className="w-1.5 h-1.5 rounded-full bg-gray-400 dark:bg-gray-500"></span>
                  {task}
                </li>
              ))}
            </ul>
          )}
        </div>
      ))}
    </div>
  );

  const ListView = () => (
    <div className="space-y-2">
      {entries.map((entry, index) => (
        <div key={index} className="bg-white dark:bg-gray-800 rounded-lg border p-3 shadow-sm hover:shadow-md transition-all duration-200">
          <div className="flex items-center gap-3">
            <input
              type="checkbox"
              checked={entry.completed}
              onChange={() => {}}
              className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <span className="text-sm font-medium text-gray-500 dark:text-gray-400 w-24">
              {entry.startTime} - {entry.endTime}
            </span>
            {entry.link ? (
              <a 
                href={entry.link}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-500 hover:text-blue-600 flex items-center gap-1 font-medium"
              >
                {entry.title}
                <Link className="w-4 h-4" />
              </a>
            ) : (
              <span className="font-medium text-gray-900 dark:text-gray-100">{entry.title}</span>
            )}
          </div>
          {entry.subTasks.length > 0 && (
            <div className="ml-7 pl-24 mt-2">
              <ul className="space-y-1">
                {entry.subTasks.map((task, idx) => (
                  <li key={idx} className="text-gray-600 dark:text-gray-400 text-sm flex items-center gap-2">
                    <span className="w-1.5 h-1.5 rounded-full bg-gray-400 dark:bg-gray-500"></span>
                    {task}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      ))}
    </div>
  );

  // Group entries by date
  const groupedEntries = entries.reduce((groups, entry) => {
    if (!groups[entry.date]) {
      groups[entry.date] = [];
    }
    groups[entry.date].push(entry);
    return groups;
  }, {} as Record<string, TimeEntry[]>);

  // Sort dates in descending order
  const sortedDates = Object.keys(groupedEntries).sort((a, b) => b.localeCompare(a));

  return (
    <div className={`min-h-screen ${isDarkMode ? 'dark' : ''}`}>
      <div className="dark:bg-gray-900 min-h-screen">
        <div className="h-screen flex">
          <div className={`flex-1 p-6 ${showCode ? 'border-r' : ''}`}>
            <div className="flex justify-between items-center mb-6">
              <div className="flex items-center gap-4">
                <button
                  onClick={() => setView(prev => {
                    const views = ['timeline', 'blocks', 'list'];
                    const currentIndex = views.indexOf(prev);
                    return views[(currentIndex + 1) % views.length];
                  })}
                  className="inline-flex items-center gap-2 px-3 py-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  {view === 'timeline' ? <Calendar className="h-4 w-4" /> :
                   view === 'blocks' ? <Layout className="h-4 w-4" /> :
                   <List className="h-4 w-4" />}
                  <span className="text-sm font-medium capitalize">{view} Ansicht</span>
                </button>
                <label className="inline-flex items-center gap-2 px-3 py-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors cursor-pointer">
                  <FolderOpen className="h-4 w-4" />
                  <span className="text-sm font-medium">Ordner öffnen</span>
                  <input
                    type="file"
                    className="hidden"
                    multiple
                    accept=".md"
                    onChange={handleFileSelect}
                    webkitdirectory=""
                    directory=""
                  />
                </label>
                {selectedFiles.length > 0 && (
                  <span className="text-sm text-gray-500 dark:text-gray-400">
                    {selectedFiles.length} Dateien geladen
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setShowCode(!showCode)}
                  className="p-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  <Code className="h-4 w-4" />
                </button>
                <button
                  onClick={() => setIsDarkMode(!isDarkMode)}
                  className="p-2 rounded-lg border bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  {isDarkMode ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div className="relative h-[calc(100vh-7rem)]">
              <div 
                ref={timelineRef}
                className="h-full overflow-y-auto pr-4 -mr-4 pb-16"
              >
                {view === 'timeline' && (
                  <div className="space-y-8">
                    {sortedDates.map(date => (
                      <div key={date} className="space-y-2">
                        <h2 className="text-lg font-semibold sticky top-0 bg-gray-100 dark:bg-gray-900 py-2 z-10">
                          {formatDate(date)}
                        </h2>
                        {groupedEntries[date].map((entry, index) => (
                          <TimelineEntry key={index} entry={entry} />
                        ))}
                      </div>
                    ))}
                  </div>
                )}
                {view === 'blocks' && <BlockView />}
                {view === 'list' && <ListView />}
              </div>

              {/* Touch Navigation Buttons */}
              <div className="fixed bottom-4 right-4 flex flex-col gap-2">
                <button
                  onClick={() => scrollTimeline('up')}
                  className="p-3 rounded-full bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow"
                >
                  <ChevronUp className="h-6 w-6" />
                </button>
                <button
                  onClick={() => scrollTimeline('down')}
                  className="p-3 rounded-full bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow"
                >
                  <ChevronDown className="h-6 w-6" />
                </button>
              </div>
            </div>
          </div>

          {showCode && (
            <div className="w-1/2 p-6 border-l bg-gray-50 dark:bg-gray-900">
              <div className="bg-white dark:bg-gray-800 rounded-lg border shadow-sm p-4">
                <h2 className="text-lg font-semibold mb-4 dark:text-white">Markdown Code</h2>
                <textarea
                  className="w-full h-[calc(100vh-12rem)] p-4 border rounded-lg font-mono text-sm bg-white dark:bg-gray-800 dark:text-gray-100 resize-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Fügen Sie Ihren Tagesplan hier ein..."
                  onChange={(e) => parseDayPlanner(e.target.value)}
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;