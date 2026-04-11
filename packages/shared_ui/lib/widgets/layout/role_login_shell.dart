import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleLoginMetric {
  const RoleLoginMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class RoleLoginPoint {
  const RoleLoginPoint({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;
}

class RoleLoginShell extends StatelessWidget {
  const RoleLoginShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.heroIcon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceTint,
    required this.metrics,
    required this.points,
    required this.formTitle,
    required this.formDescription,
    required this.form,
    this.formHighlights = const <String>[],
    this.heroFootnote,
    this.supportNote,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData heroIcon;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceTint;
  final List<RoleLoginMetric> metrics;
  final List<RoleLoginPoint> points;
  final String formTitle;
  final String formDescription;
  final Widget form;
  final List<String> formHighlights;
  final String? heroFootnote;
  final String? supportNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              primaryColor.withValues(alpha: 0.16),
              surfaceTint,
              secondaryColor.withValues(alpha: 0.10),
              Colors.white,
            ],
            stops: const <double>[0, 0.35, 0.72, 1],
          ),
        ),
        child: Stack(
          children: <Widget>[
            _BackdropOrb(
              alignment: Alignment.topLeft,
              color: primaryColor.withValues(alpha: 0.16),
              size: 260,
              offset: const Offset(-70, -60),
            ),
            _BackdropOrb(
              alignment: Alignment.bottomRight,
              color: secondaryColor.withValues(alpha: 0.14),
              size: 320,
              offset: const Offset(80, 90),
            ),
            _BackdropOrb(
              alignment: Alignment.centerRight,
              color: primaryColor.withValues(alpha: 0.08),
              size: 180,
              offset: const Offset(70, 0),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 980;
                        final isCompact = constraints.maxWidth < 760;
                        final heroPanel = _RoleHeroPanel(
                          eyebrow: eyebrow,
                          title: title,
                          description: description,
                          heroIcon: heroIcon,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          metrics: metrics,
                          points: points,
                          heroFootnote: heroFootnote,
                          compact: isCompact,
                        );
                        final formPanel = _RoleFormPanel(
                          heroIcon: heroIcon,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                          formTitle: formTitle,
                          formDescription: formDescription,
                          formHighlights: formHighlights,
                          supportNote: supportNote,
                          compact: isCompact,
                          child: form,
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(flex: 11, child: heroPanel),
                              const SizedBox(width: 28),
                              Expanded(flex: 9, child: formPanel),
                            ],
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            formPanel,
                            const SizedBox(height: 20),
                            heroPanel,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleHeroPanel extends StatelessWidget {
  const _RoleHeroPanel({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.heroIcon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.metrics,
    required this.points,
    required this.compact,
    this.heroFootnote,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData heroIcon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<RoleLoginMetric> metrics;
  final List<RoleLoginPoint> points;
  final bool compact;
  final String? heroFootnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primaryColor,
            Color.lerp(primaryColor, secondaryColor, 0.35)!,
            secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 28 : 34),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 24 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 7 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    eyebrow,
                    style: GoogleFonts.nunitoSans(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: compact ? 52 : 62,
                  height: compact ? 52 : 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Icon(heroIcon, color: Colors.white, size: compact ? 24 : 30),
                ),
              ],
            ),
            SizedBox(height: compact ? 22 : 30),
            Text(
              title,
              style: GoogleFonts.sora(
                fontSize: compact ? 30 : 40,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
                description,
                style: GoogleFonts.nunitoSans(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w600,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.90),
                ),
              ),
            ),
            SizedBox(height: compact ? 20 : 26),
            Wrap(
              spacing: compact ? 10 : 14,
              runSpacing: compact ? 10 : 14,
              children: metrics
                  .map(
                    (metric) => _MetricCard(
                      metric: metric,
                      accent: secondaryColor,
                      compact: compact,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: compact ? 20 : 26),
            Container(
              padding: EdgeInsets.all(compact ? 18 : 22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(compact ? 22 : 28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'What this space helps you do',
                    style: GoogleFonts.sora(
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RolePointRow(
                        point: point,
                        accent: secondaryColor,
                        compact: compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (heroFootnote != null) ...<Widget>[
              const SizedBox(height: 20),
              Text(
                heroFootnote!,
                style: GoogleFonts.nunitoSans(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleFormPanel extends StatelessWidget {
  const _RoleFormPanel({
    required this.heroIcon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.formTitle,
    required this.formDescription,
    required this.formHighlights,
    required this.child,
    required this.compact,
    this.supportNote,
  });

  final IconData heroIcon;
  final Color primaryColor;
  final Color secondaryColor;
  final String formTitle;
  final String formDescription;
  final List<String> formHighlights;
  final Widget child;
  final bool compact;
  final String? supportNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(compact ? 28 : 34),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 24 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: compact ? 64 : 74,
              height: compact ? 64 : 74,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    primaryColor,
                    secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(compact ? 20 : 24),
              ),
              child: Icon(heroIcon, color: Colors.white, size: compact ? 30 : 34),
            ),
            SizedBox(height: compact ? 18 : 22),
            Text(
              formTitle,
              style: GoogleFonts.sora(
                fontSize: compact ? 24 : 28,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formDescription,
              style: GoogleFonts.nunitoSans(
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: const Color(0xFF5E6675),
              ),
            ),
            if (formHighlights.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: formHighlights
                    .map(
                      (highlight) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          highlight,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            SizedBox(height: compact ? 22 : 28),
            child,
            if (supportNote != null) ...<Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  supportNote!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: const Color(0xFF475061),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.accent,
    required this.compact,
  });

  final RoleLoginMetric metric;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: compact ? 130 : 160),
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(metric.icon, size: compact ? 18 : 20, color: accent),
          SizedBox(height: compact ? 10 : 12),
          Text(
            metric.value,
            style: GoogleFonts.sora(
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            style: GoogleFonts.nunitoSans(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePointRow extends StatelessWidget {
  const _RolePointRow({
    required this.point,
    required this.accent,
    required this.compact,
  });

  final RoleLoginPoint point;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
          ),
          child: Icon(point.icon, color: accent, size: compact ? 18 : 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                point.title,
                style: GoogleFonts.nunitoSans(
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                point.detail,
                style: GoogleFonts.nunitoSans(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({
    required this.alignment,
    required this.color,
    required this.size,
    required this.offset,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  color,
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}