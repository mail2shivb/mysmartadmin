import 'package:flutter/material.dart';

/// Documents management screen (temporarily disabled)
class DocumentsFunctionalScreen extends StatelessWidget {
  const DocumentsFunctionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Documents UI disabled temporarily'),
      ),
    );
  }
}

/*
// ORIGINAL CODE COMMENTED OUT FOR STABILIZATION

import 'package:flutter/material.dart';
import '../../core/database_provider.dart';
import '../../domain/usecases/documents/add_document_usecase.dart';
import '../../domain/usecases/documents/get_documents_usecase.dart';
import '../../domain/usecases/documents/delete_document_usecase.dart';
import '../../domain/usecases/documents/link_document_usecase.dart';
import '../../data/local/tables/documents.dart';

/// Documents management screen
class DocumentsFunctionalScreen extends StatefulWidget {
  const DocumentsFunctionalScreen({super.key});

  @override
  State<DocumentsFunctionalScreen> createState() => _DocumentsFunctionalScreenState();
}

class _DocumentsFunctionalScreenState extends State<DocumentsFunctionalScreen> {
  final _database = DatabaseProvider.instance;
  late final _addDocumentUseCase = AddDocumentUseCase(_database);
  late final _getDocumentsUseCase = GetDocumentsUseCase(_database);
  late final _deleteDocumentUseCase = DeleteDocumentUseCase(_database);
  late final _linkDocumentUseCase = LinkDocumentUseCase(_database);

  List<DocumentEntity> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loading = true);
    try {
      final documents = await _getDocumentsUseCase();
      setState(() {
        _documents = documents;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddDocumentDialog() async {
    final titleController = TextEditingController();
    String? documentType = 'receipt';
    String? category = 'Finance';
    DateTime? documentDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: documentType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'receipt', child: Text('Receipt')),
                    DropdownMenuItem(value: 'invoice', child: Text('Invoice')),
                    DropdownMenuItem(value: 'contract', child: Text('Contract')),
                    DropdownMenuItem(value: 'certificate', child: Text('Certificate')),
                  ],
                  onChanged: (value) => setDialogState(() => documentType = value),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                    DropdownMenuItem(value: 'Property', child: Text('Property')),
                    DropdownMenuItem(value: 'Vehicle', child: Text('Vehicle')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Date: ${_formatDate(documentDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: documentDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() => documentDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                try {
                  await _addDocumentUseCase(
                    title: title,
                    documentType: documentType ?? 'other',
                    category: category ?? 'Other',
                    filePath: '/mock/path/${title.replaceAll(' ', '_')}.pdf',
                    fileType: 'application/pdf',
                    fileSizeBytes: 1024,
                    documentDate: documentDate,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document added')),
                    );
                    _loadDocuments();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocument(DocumentEntity document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.title}"?\nAll links will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await _deleteDocumentUseCase(document.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document and links deleted')),
          );
          _loadDocuments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete document')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _linkDocument(DocumentEntity sourceDoc) async {
    if (_documents.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 2 documents to link')),
      );
      return;
    }

    final targetDoc = await showDialog<DocumentEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link To Document'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _documents
                .where((d) => d.id != sourceDoc.id)
                .map((doc) => ListTile(
                      title: Text(doc.title),
                      subtitle: Text(doc.documentType),
                      onTap: () => Navigator.pop(context, doc),
                    ))
                .toList(),
          ),
        ),
      ),
    );

    if (targetDoc == null) return;

    try {
      await _linkDocumentUseCase(
        sourceDocumentId: sourceDoc.id,
        targetDocumentId: targetDoc.id,
        linkType: 'related',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Linked to ${targetDoc.title}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? const Center(child: Text('No documents yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final document = _documents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(document.title),
                        subtitle: Text(
                          '${document.documentType} • ${document.category}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'link',
                              child: Row(
                                children: [
                                  Icon(Icons.link),
                                  SizedBox(width: 8),
                                  Text('Link'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'link') {
                              _linkDocument(document);
                            } else if (value == 'delete') {
                              _deleteDocument(document);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDocumentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/
